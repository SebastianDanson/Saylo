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
    var isMiniDisplay: Bool
    
    init(url: URL, isVideo: Bool, isMiniDisplay: Bool = false) {
        
        let player = AVPlayer(url: url)
        self._player = State(initialValue: player)
        player.automaticallyWaitsToMinimizeStalling = false
        
        self.isVideo = isVideo
        self.isMiniDisplay = isMiniDisplay
    }
    
    var body: some View {
        
        
        PlayerView(player: $player, shouldLoop: false)
            .frame(width: isMiniDisplay ? MINI_MESSAGE_WIDTH : CAMERA_WIDTH, height: isMiniDisplay ? MINI_MESSAGE_HEIGHT : CAMERA_HEIGHT)
            .onAppear {
                
                if !isMiniDisplay {
                    ConversationViewModel.shared.currentPlayer = player
                    player.playWithRate()
                } else {
                    player.pause()
                }
            }
            .onDisappear {
                if !isMiniDisplay {
                    player.pause()
                }
            }
            .background(isVideo ? Color.systemBlack :  Color.mainBlue)
            .cornerRadius(isMiniDisplay ? 6 : 16)
            .overlay(
                ZStack {
                    if !isVideo {
                        Image(systemName: "waveform")
                            .resizable()
                            .frame(width: isMiniDisplay ? 20 : 120, height: isMiniDisplay ? 2 : 120)
                            .foregroundColor(.white)
                            .scaledToFill()
                            .padding(.top, isMiniDisplay ? 2 : 8)
                    }
                }
            )
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.player = player
    }
}

