//
//  VideoPlayerViewModel.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import Foundation
import Firebase
import AVFoundation

class VideoPlayerViewModel: ObservableObject {
    
    @Published var player: AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func togglePlay() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
