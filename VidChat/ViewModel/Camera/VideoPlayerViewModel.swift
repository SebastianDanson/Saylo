//
//  VideoPlayerViewModel.swift
//  Saylo
//
//  Created by Student on 2021-10-14.
//

import Foundation
import Firebase
import AVFoundation

class VideoPlayerViewModel: ObservableObject {
    
    @Published var player: AVPlayer
    
    var date: Date?
    
    init(player: AVPlayer, date: Date? = nil) {
        self.player = player
        self.date = date
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
