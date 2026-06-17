//
//  PolaroidSoundPlayer.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import AVFoundation
import UIKit

@MainActor
final class PolaroidSoundPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = PolaroidSoundPlayer()

    private var player: AVAudioPlayer?

    func playEjectSound() -> TimeInterval {
        if player == nil {
            guard let asset = NSDataAsset(name: "PolaroidEject") else { return 3.05 }
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? session.setActive(true, options: [])

            player = try? AVAudioPlayer(data: asset.data)
            guard let player else { return 3.05 }
            player.delegate = self
            player.prepareToPlay()
        }
        player?.currentTime = 0
        player?.play()
        return player!.duration
    }
}
