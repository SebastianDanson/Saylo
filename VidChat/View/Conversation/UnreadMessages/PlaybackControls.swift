//
//  PlaybackControls.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-17.
//

import SwiftUI
import AVKit

struct PlaybackControls: View {
    
    @Binding var showPlaybackControls: Bool
    @Binding var sliderValue: Double
    
    let viewModel = ConversationViewModel.shared
    
    var body: some View {
        
        HStack {
            
            Button {
                handleChangeCurrentTime(seconds: -5.0)
            } label: {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            
            
            Spacer()
            
            Button {
                viewModel.showPreviousMessage()
                showPlaybackControls = false
            } label: {
                Image(systemName: "backward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .font(Font.title.weight(.ultraLight))
                    .frame(width: 28, height: 28)
            }
            
            Spacer()
            
            Button {
                viewModel.toggleIsPlaying()
                showPlaybackControls = false
            } label: {
                Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .font(Font.title.weight(.regular))
                    .frame(width: 42, height: 42)
            }
            
            Spacer()
            
            Button {
                viewModel.showNextMessage()
                showPlaybackControls = false
            } label: {
                Image(systemName: "forward.end.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .font(Font.title.weight(.ultraLight))
                    .frame(width: 28, height: 28)
            }
            
            Spacer()
            
            Button {
                handleChangeCurrentTime(seconds: 10.0)
            } label: {
                Image(systemName: "goforward.10")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                
            }
            
        }
        
    }
    
    func handleChangeCurrentTime(seconds: Double) {
        
        showPlaybackControls = false
        let currentTime = viewModel.currentPlayer?.currentItem?.currentTime().seconds ?? .zero
        let duration = viewModel.currentPlayer?.currentItem?.asset.duration ?? .zero
        let newTime = max(currentTime + seconds, 0.0)
        
        if newTime > duration.seconds  {
            viewModel.showNextMessage()
        } else {
            let targetTime: CMTime = CMTime(seconds: newTime, preferredTimescale: 1)
            
            sliderValue = newTime / duration.seconds
            viewModel.currentPlayer?.seek(to: targetTime)
        }
        
        viewModel.toggleIsPlaying()
    }
}

//struct PlaybackControls_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaybackControls()
//    }
//}
