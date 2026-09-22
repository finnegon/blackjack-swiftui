import AVFoundation

@MainActor
final class SoundPlayer {
    static let shared = SoundPlayer()
    
    enum Effect: String, CaseIterable {
        case deal, flip, win, lose, push
    }
    
    private var players: [Effect: AVAudioPlayer] = [:]
    
    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default)
        try? session.setActive(true)
        
        for effect in Effect.allCases {
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[effect] = player
        }
    }
    
    func play(_ effect: Effect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }
}
