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
    var messageId: String?
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var isSaved: Bool
    @State var showAlert = false

    init(audioURL: URL, date: Date, isSaved: Bool, messagId: String) {
        self.date = date
        self.audioURL = audioURL
        self.messageId = messagId
        self._isSaved = State(initialValue: isSaved)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 9) {
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
                        .foregroundColor(.topGray)
                        .scaledToFill()
                        .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .overlay(
        ZStack {
            if isSaved {
                Button {
                    showAlert = true
                } label: {
                    ZStack {
                        
                        Circle()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(white: 0, opacity: 0.3))
                        
                        Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 13, height: 13)
                    }
                    .padding(.horizontal, 8)
                }.alert(isPresented: $showAlert) {
                    savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == messageId}), completion: { isSaved in
                        self.isSaved = isSaved
                    })
                }
            }
        }
        ,alignment: .topTrailing)
        .background(Color.white)
        .padding(.trailing, 10)
        .padding(.leading, 17)
        .padding(.bottom, 12)
        .padding(.top, 4)
        .onLongPressGesture(perform: {
            withAnimation {
                if let i = getMessages().firstIndex(where: {$0.id == messageId}) {
                    if getMessages()[i].isSaved {
                        showAlert = true
                    } else {
                        ConversationViewModel.shared.updateIsSaved(atIndex: i)
                        isSaved.toggle()
                    }
               
                }
            }
        })
    }
}

//struct AudioCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioCell()
//    }
//}
