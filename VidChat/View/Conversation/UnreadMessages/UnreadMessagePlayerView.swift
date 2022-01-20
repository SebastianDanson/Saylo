//
//  UnreadMessagePlayerView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-20.
//

import SwiftUI
import AVFoundation

struct UnreadMessagePlayerView: View {
    
    @State var player: AVPlayer
    
    init(url: URL) {
        let player = AVPlayer(url: url)
        self._player = State(initialValue: player)
        player.automaticallyWaitsToMinimizeStalling = false
    }
    
    var body: some View {
        
        PlayerView(player: $player, shouldLoop: false)
            .frame(width: CAMERA_SMALL_WIDTH, height: CAMERA_SMALL_HEIGHT)
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
            
    }
}

