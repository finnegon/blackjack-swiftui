import Foundation

enum Suit: String, CaseIterable {
    case diamonds
    case clubs
    case hearts
    case spades
    
    // fallback UI incase assets don't render
    var symbol: String {
        switch self {
        case .diamonds:
            return "suit.diamond.fill"
        case .clubs:
            return "suit.club.fill"
        case .hearts:
            return "suit.heart.fill"
        case .spades:
            return "suit.spade.fill"
        }
    }
}

enum Rank: CaseIterable {
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace

    var value: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten, .jack, .queen, .king: return 10
        case .ace: return 11
        }
    }

    var label: String {
        switch self {
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        case .ace:
            return "A"
        case .two,
            .three,
            .four,
            .five,
            .six,
            .seven,
            .eight,
            .nine,
            .ten:
            return String(value)
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    let suit: Suit
    let rank: Rank
}

extension Card {
    var assetName: String {
        "card_\(suit.rawValue)_\(rank.label)"
    }
    
    static let backAssetName = "card_back_blue"
}
