//
//  AudioCell.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import SwiftUI

struct AudioCell: View {
    
    var audioURL: URL
    var date: Date
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "house")
                .clipped()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Sebastian")
                    .font(.system(size: 14, weight: .semibold))
                + Text(" • \(date.getFormattedDate())")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.mainGray)
                Button {
                    if !audioPlayer.isPlaying {
                        audioPlayer.hasFinished ? audioPlayer.startPlayback(audio: self.audioURL) : audioPlayer.resume()
                    } else {
                        audioPlayer.pause()
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
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

//struct AudioCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioCell()
//    }
//}
