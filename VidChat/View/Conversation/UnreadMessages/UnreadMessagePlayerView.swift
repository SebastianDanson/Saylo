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
            .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
            .onAppear {
                
                if !isMiniDisplay {
                    ConversationViewModel.shared.currentPlayer = player
                    player.playWithRate()
                    
                    ConversationViewModel.shared.setVideoLength()

                } else {
                    player.pause()
                }
            }
            .onDisappear {
                if !isMiniDisplay {
                    player.pause()
                }
            }
            .background(isVideo ? Color.systemBlack :  Color.alternateMainBlue)
            .cornerRadius(14, corners: [.topLeft, .topRight])
            .overlay(
                ZStack {
                    if !isVideo {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isMiniDisplay ? 20 : 120, height: isMiniDisplay ? 2 : 120)
                            .foregroundColor(.white)
                            .padding(.top, isMiniDisplay ? 2 : 8)
                    }
                }
            )
    }
    
    func setPlayer(_ player: AVPlayer) {
        self.player = player
    }
}

