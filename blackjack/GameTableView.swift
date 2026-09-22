import SwiftUI

struct GameTableView: View {
    @State private var game = Game()
    @State private var showRules = false
    @State private var showResult = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var actionAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.75)
    }
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack(spacing: 24) {
                dealerSection
                Spacer()
                if game.state != .roundOver {
                    statusSection
                }
                Spacer()
                playerSection
                controlsSection
            }
            .padding()
            
            if showResult && game.state == .roundOver {
                resultOverlay()
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
        .onTapGesture(count: 2)  {
            if canDeal {
                withAnimation(actionAnimation) { game.deal() }
            }
        }
        .simultaneousGesture(longPressGesture)
        .sheet(isPresented: $showRules) {
            RulesView()
        }
        .task(id: game.state) {
            
            if game.state != .roundOver {
                showResult = false
            }
            
            switch game.state {
            case .blackjack:
                try? await Task.sleep(for: .seconds(0.8))
                if game.state == .blackjack {
                    withAnimation(actionAnimation) { game.revealAndEvaluate() }
                }
            case .roundOver:
                try? await Task.sleep(for: .seconds(0.6))
                if game.state == .roundOver {
                    withAnimation(actionAnimation) { showResult = true }
                    playResultSound()
                }
            default:
                break
            }
        }
        .onChange(of: game.player.cards.count) { oldValue, newValue in
            if newValue > oldValue { SoundPlayer.shared.play(.deal) }
        }
        .onChange(of: game.dealerHoleHidden) { _, hidden in
            if !hidden { SoundPlayer.shared.play(.flip) }
        }
    }
    
    private var canDeal: Bool {
        game.state == .idle || game.state == .roundOver
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let dy = value.translation.height
                let dx = value.translation.width
                
                guard abs(dy) > abs(dx) else { return }
                
                if dy < 0 {
                    withAnimation(actionAnimation) { game.hit() }
                } else {
                    withAnimation(actionAnimation) { game.stand() }
                }
            }
    }
    
    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in showRules = true }
    }
    
    private var dealerSection: some View {
        VStack(spacing: 8) {
            Text("Dealer \(dealerTotalText)")
                .font(.caption).bold()
                .foregroundStyle(.white.opacity(0.8))
            
            HStack(spacing: -20) {
                ForEach(Array(game.dealer.cards.enumerated()), id: \.element.id) {
                    index, card in CardView(card: card, isFaceDown: index == 1 && game.dealerHoleHidden)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private var playerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: -20) {
                ForEach(game.player.cards) {
                    card in CardView(card: card)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            Text("Player \(playerTotalText)")
                .font(.caption).bold()
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    private var statusSection: some View {
        Text(statusText)
            .font(.headline)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private var controlsSection: some View {
        HStack(spacing: 16) {
            if game.state == .playerTurn {
                controlButton("HIT", .blue) { withAnimation(actionAnimation) { game.hit() }
                }
                controlButton("STAND", .red) {
                    withAnimation(actionAnimation) { game.stand() }
                }
            } else if game.state == .idle || game.state == .roundOver {
                controlButton("DEAL", .orange) {
                    withAnimation(actionAnimation) { game.deal() }
                }
            }
        }
        .padding()
    }
    
    private func resultOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(statusText)
                    .font(.title2).bold()
                    .foregroundStyle(.white)
                
                controlButton("PLAY AGAIN", .orange) {
                    withAnimation(actionAnimation) { game.deal() }
                }
            }
            .padding()
        }
    }
    
    private var playerTotalText: String {
        game.player.cards.isEmpty ? "" : "\(game.player.total)"
    }

    private var dealerTotalText: String {
        if game.dealer.cards.isEmpty { return "" }
        return game.dealerHoleHidden ? "?" : "\(game.dealer.total)"
    }
    
    private var statusText: String {
        switch game.state {
        case .idle: return "Tap Deal to Start"
        case .playerTurn: return "Your Turn"
        case .blackjack: return "Blackjack!"
        case .dealerTurn: return "Dealer's Turn"
        case .roundOver:
            switch game.outcome {
            case .playerBlackjack: return "Blackjack, you win!"
            case .playerWin: return "You win!"
            case .dealerBust: return "Dealer busts, you win!"
            case .playerBust: return "Bust, you lose."
            case .dealerWin: return "Dealer wins."
            case .dealerBlackjack: return "Dealer blackjack, you lose."
            case .push: return "Push, it is a draw."
            case .none: return ""
            }
        
        }
    }
    
    private func controlButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(width: 110, height: 50)
                .background(color)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    private struct PressableButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.94 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
    
    private func playResultSound() {
        switch game.outcome {
        case .playerBlackjack, .playerWin, .dealerBust:
            SoundPlayer.shared.play(.win)
        case .playerBust, .dealerWin, .dealerBlackjack:
            SoundPlayer.shared.play(.lose)
        case .push:
            SoundPlayer.shared.play(.push)
        case .none:
            break
        }
    }
    
}

#Preview {
    GameTableView()
}
