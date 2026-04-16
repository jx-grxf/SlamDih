import AVFoundation
import Foundation

final class SoundPlayer {
    private var player: AVAudioPlayer?

    init() {
        guard let url = Bundle.module.url(forResource: "SlapSoundEffect", withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            self.player = player
        } catch {
            self.player = nil
        }
    }

    var isReady: Bool {
        player != nil
    }

    func play() {
        guard let player else {
            return
        }

        player.currentTime = 0
        player.play()
    }
}
