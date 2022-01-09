//
//  AudioCell.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import SwiftUI
import Kingfisher

struct AudioCell: View {
    
    var audioURL: URL
    var date: Date
    var messageId: String?
    var profileImageUrl: String
    var name: String
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var isSaved: Bool
    @State var showAlert = false
    
    init(message: Message, audioUrl: URL) {
        self.date = message.timestamp.dateValue()
        self.audioURL = audioUrl
        self.messageId = message.id
        self.name = message.username
        self.profileImageUrl = message.userProfileImageUrl
        self._isSaved = State(initialValue: message.isSaved)
    }
    
    var body: some View {
        ZStack {
        HStack(alignment: .top, spacing: 9) {
            
//            KFImage(URL(string: self.profileImageUrl))
//                .resizable()
//                .scaledToFill()
//                .frame(width: 30, height: 30)
//                .clipShape(Circle())
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(name)
//                    .font(.system(size: 14, weight: .semibold))
//                + Text(" • \(date.getFormattedDate())")
//                    .font(.system(size: 12, weight: .regular))
//                    .foregroundColor(.mainGray)
            Spacer()

                Button {
                    if !audioPlayer.isPlaying {
                        audioPlayer.hasFinished ? audioPlayer.startPlayback(audio: self.audioURL) : audioPlayer.resume()
                    } else {
                        audioPlayer.pause()
                    }
                } label: {
                    
                        
                        Image(systemName: audioPlayer.isPlaying ?
                              "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding(.leading, audioPlayer.isPlaying ? 0 : 10)
                                               
                        
//                }
            }
            
            Spacer()
        }
        .frame(width: SCREEN_WIDTH - 10, height: SCREEN_WIDTH * 16/18)
        .overlay(
            MessageInfoView(date: date, profileImage: profileImageUrl, name: name)
                .padding(.horizontal, 12)
                .padding(.vertical, 26), alignment: .bottomLeading)
        }
//        .frame(width: SCREEN_WIDTH - 10, height: SCREEN_WIDTH * 16/18)
        .background(Color.mainBlue)
        .cornerRadius(12)
        .overlay(
            ZStack {
                if isSaved {
                    Button {
                        showAlert = true
                    } label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.point3AlphaSystemBlack)
                            
                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.systemWhite)
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
        .padding(.vertical, 8)
//        .background(Color.systemWhite)
//        .padding(.trailing, 10)
//        .padding(.leading, 17)
//        .padding(.bottom, 12)
//        .padding(.top, 4)
//        .onLongPressGesture(perform: {
//            withAnimation {
//                if let i = getMessages().firstIndex(where: {$0.id == messageId}) {
//                    if getMessages()[i].isSaved {
//                        showAlert = true
//                    } else {
//                        ConversationViewModel.shared.updateIsSaved(atIndex: i)
//                        isSaved.toggle()
//                    }
//
//                }
//            }
//        })
    }
}

//struct AudioCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioCell()
//    }
//}
