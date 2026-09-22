
import SwiftUI

struct CardView: View {
    let card: Card
    var isFaceDown: Bool = false
    var width: CGFloat = 70
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double
    
    init(card: Card, isFaceDown: Bool = false, width: CGFloat = 70) {
        self.card = card
        self.isFaceDown = isFaceDown
        self.width = width
        _rotation = State(initialValue: isFaceDown ? 180 : 0)
    }
    
    private var height: CGFloat { width * 124.0 / 88.0 }
    private var showingBack: Bool { rotation >= 90 }
    
    var body: some View {
        ZStack {
            Image(card.assetName)
                .resizable().scaledToFit()
                .opacity(showingBack ? 0 : 1)
            
            Image(Card.backAssetName)
                .resizable().scaledToFit()
                .opacity(showingBack ? 1 : 0)
        }
        .frame(width: width, height: height)
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .onChange(of: isFaceDown) { _, faceDown in
            let target: Double = faceDown ? 180 : 0
            if reduceMotion {
                rotation = target
            } else {
                withAnimation(.easeInOut(duration: 0.45)) { rotation = target }
            }
        }
        .shadow(radius: 4)
    }
}

#Preview("Single Cards") {
    HStack(spacing: -20) {
        CardView(card: Card(suit: .hearts, rank: .ace))
        CardView(card: Card(suit: .spades, rank: .king))
        CardView(card: Card(suit: .diamonds, rank: .ten), isFaceDown: true)
    }
    .padding()
    .background(Color.green)
}

#Preview("All 52") {
    let suits: [Suit] = [.diamonds, .clubs, .hearts, .spades]
    return ScrollView {
        ForEach(suits, id: \.self) {
            suit in HStack(spacing: 4) {
                ForEach(Rank.allCases, id: \.self) {
                    rank in CardView(card: Card(suit:suit, rank: rank), width: 44)
                }
            }
        }
        .padding()
    }
    .background(Color.green)
}
