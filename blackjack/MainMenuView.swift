import SwiftUI

struct MainMenuView: View {
    @State private var showRules = false
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                Image(systemName: "suit.spade.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
                Text("Blackjack")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
                
                Spacer()
                
                NavigationLink {
                    GameTableView()
                } label: {
                    menuButton("PLAY", .orange)
                }
                
                Button { showRules = true } label: {
                    menuButton("RULES", .white.opacity(0.25))
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showRules) {
            RulesView()
        }
    }
    
    private func menuButton(_ title: String, _ color: Color) -> some View {
        Text(title)
            .font(.title3).bold()
            .frame(width:220, height: 56)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack{
        MainMenuView()
    }
}
