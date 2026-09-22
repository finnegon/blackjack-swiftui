import Foundation

@Observable
final class Game {
    
    enum State {
        case idle
        case playerTurn
        case blackjack
        case dealerTurn
        case roundOver
    }
    
    enum Outcome {
        case playerBlackjack
        case dealerBlackjack
        case playerWin
        case dealerWin
        case push
        case playerBust
        case dealerBust
    }
    
    private(set) var deck = Deck()
    private(set) var player = Hand()
    private(set) var dealer = Hand()
    
    private(set) var state: State = .idle
    private(set) var outcome: Outcome?
    
    var dealerHoleHidden = true
    
    func deal() {
        player.clear()
        dealer.clear()
        outcome = nil
        dealerHoleHidden = true
        
        reshuffleIfNeeded()
        
        for _ in 0..<2 {
            guard let card = deck.draw() else { break }
            player.add(card)
        }
        
        for _ in 0..<2 {
            guard let card = deck.draw() else { break }
            dealer.add(card)
        }
        
        if player.isBlackjack {
            state = .blackjack
        } else {
            state = .playerTurn
        }
    }
    
    func revealAndEvaluate() {
        guard state == .blackjack else { return }
        dealerHoleHidden = false
        evaluate()
    }
    
    func hit() {
        guard state == .playerTurn else { return }
        guard let card = deck.draw() else { return }
        player.add(card)
        
        if player.isBust {
            dealerHoleHidden = false
            evaluate()
        } else if player.total == 21 {
            stand()
        }
    }
    
    func stand() {
        guard state == .playerTurn else { return }
        dealerHoleHidden = false
        state = .dealerTurn
        dealerPlay()
    }
    
    func restart() {
        outcome = nil
        state = .idle
    }
    
    private func dealerPlay() {
        while dealer.total < 17 {
            guard let card = deck.draw() else { break }
            dealer.add(card)
        }
        
        evaluate()
    }
    
    private func evaluate() {
        if player.isBust {
            outcome = .playerBust
        } else if dealer.isBust {
            outcome = .dealerBust
        } else if player.isBlackjack && dealer.isBlackjack {
            outcome = .push
        } else if player.isBlackjack {
            outcome = .playerBlackjack
        } else if dealer.isBlackjack {
            outcome = .dealerBlackjack
        } else if player.total > dealer.total {
            outcome = .playerWin
        } else if player.total < dealer.total {
            outcome = .dealerWin
        } else {
            outcome = .push
        }
        
        state = .roundOver
    }
    
    private func reshuffleIfNeeded() {
        if deck.count < 15 {
            deck = Deck()
        }
    }
}
