import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section("Objective") {
                        Text("Get a hand total closer to 21 than the dealer's, without going over 21.")
                    }
                    
                    section("Cards Value") {
                        Text("Number Cards (2 - 10): face value")
                        Text("J, Q, K: 10 points")
                        Text("Ace: 11 or 1, whichever keeps you from busting")
                        Text("A two-card 21 is a blackjack and beats a three-card 21.")
                    }
                    
                    section("How To Play") {
                        Text("Tap DEAL to start a round. HIT draws another card; going over 21 busts and you lose. STAND ends your turn, then the dealer draws to 17. Equal totals are a push aka draw.")
                    }
                    
                    section("Gestures") {
                        ruleRow(icon: "arrow.up", title: "Swipe Up", detail: "Hit, draw another card")
                        ruleRow(icon: "arrow.down", title: "Swipe Down", detail: "Stand, end your turn")
                        ruleRow(icon: "hand.tap", title: "Double Tap", detail: "Deal or Restart the round")
                        ruleRow(icon: "hand.point.up.left", title: "Long Press", detail: "Show Rules & Hints")
                    }
                    
                    section("Buttons") {
                        Text("HIT and STAND appear during your turn, DEAL starts or restarts a round.")
                    }
                }
                .padding()
                
                .navigationTitle("Rules")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {dismiss()}
                    }
                }
            }
        }
    }
    
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    private func ruleRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).bold().foregroundStyle(.primary)
                Text(detail).font(.footnote)
            }
            Spacer()
        }
    }
}

#Preview {
    RulesView()
}
