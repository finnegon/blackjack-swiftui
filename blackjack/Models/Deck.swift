import Foundation

struct Deck {
    private(set) var cards: [Card] = []
    
    init(shuffled: Bool = true) {
        cards = Deck.standardOrder()
        if shuffled {
            cards.shuffle()
        }
    }
    
    private static func standardOrder() -> [Card] {
        var ordered: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                ordered.append(Card(suit: suit, rank: rank))
            }
        }
        return ordered
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    mutating func draw() -> Card? {
        cards.popLast()
    }
    
    mutating func reset() {
        cards = Deck.standardOrder()
        cards.shuffle()
    }
    
    var count: Int { cards.count }
    var isEmpty: Bool { cards.isEmpty }
}

