//
//  AudioCell.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import SwiftUI

struct AudioCell: View {
    
    var audioURL: URL
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "house")
                .clipped()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Sebastian")
                    .font(.system(size: 14, weight: .semibold))
                Button {
                    if !audioPlayer.isPlaying {
                        self.audioPlayer.startPlayback(audio: self.audioURL)
                    } else {
                        self.audioPlayer.stopPlayback()
                    }
                } label: {
                    Image(systemName: audioPlayer.isPlaying ?
                          "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.mainBlue)
                        .scaledToFill()
                        .padding(.top, 8)
                }
            }
            Spacer()
        }.padding(.horizontal)
    }
}

//struct AudioCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioCell()
//    }
//}
