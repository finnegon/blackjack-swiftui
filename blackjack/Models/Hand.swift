import Foundation

struct Hand {
    private(set) var cards: [Card] = []
    
    mutating func add(_ card: Card) {
        cards.append(card)
    }
    
    mutating func clear() {
        cards.removeAll()
    }
    
    var total: Int {
        var sum = 0
        var aces = 0
        
        for card in cards {
            if card.rank == .ace {
                aces += 1
                sum += 11
            } else {
                sum += card.rank.value
            }
        }
        
        while sum > 21 && aces > 0 {
            sum -= 10
            aces -= 1
        }
        return sum
    }
    
    var isBust: Bool {
        total > 21
    }
    
    var isBlackjack: Bool {
        cards.count == 2 && total == 21
    }
    
    var isEmpty: Bool {
        cards.isEmpty
    }
}
