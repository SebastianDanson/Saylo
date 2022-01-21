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
    var isVideo: Bool
    
    init(url: URL, isVideo: Bool) {
        let player = AVPlayer(url: url)
        self._player = State(initialValue: player)
        player.automaticallyWaitsToMinimizeStalling = false
        
        self.isVideo = isVideo
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
            .background(isVideo ? Color.systemBlack :  Color.mainBlue)
            .cornerRadius(22)
            .overlay(
                ZStack {
                    if !isVideo {
                        Image(systemName: "waveform")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)
                            .scaledToFill()
                            .padding(.top, 8)
                    }
                }
            )
            
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.player = player
    }
}

