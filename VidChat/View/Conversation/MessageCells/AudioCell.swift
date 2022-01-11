//
//  AudioCell.swift
//  VidChat
//
//  Created by Student on 2021-10-14.
//

import SwiftUI
import Kingfisher
import AVFoundation

struct AudioCell: View {
    
//    var audioURL: URL
    var message: Message
    @ObservedObject var audioPlayer = AudioPlayer()
//    @State var isSaved: Bool
    @State var showAlert = false
    @State var player: AVPlayer
    
    init(message: Message, audioUrl: URL) {
        self.message = message
//        self.audioURL = audioUrl
        
//        self._isSaved = State(initialValue: message.isSaved)

//        let player = AVPlayer(url: audioUrl)
        self.player = AVPlayer(url: audioUrl)
        
        player.automaticallyWaitsToMinimizeStalling = false
        

        
        //        if let id = message?.id, let lastMessageId = ConversationViewModel.shared.messages.last?.id, id == lastMessageId {
        //            player.play()
        //        }
    }
    
    var body: some View {
        
        let videoCell = VideoCell(message: message)
        
        ZStack {
            
           videoCell
               .overlay(
                    
                    VStack {
                        
                    KFImage(URL(string: message.userProfileImageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        
                        Text(message.username)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                )
            
            
                  
        }
        .background(Color.mainBlue)
        .frame(width: SCREEN_WIDTH - 10, height: (SCREEN_WIDTH) * 16/9)
        .cornerRadius(16)
        .padding(.vertical, 8)
//        .highPriorityGesture(TapGesture()
//                                .onEnded { _ in
//            
//            togglePlay()
//        })
//        .onAppear {
//            //                    if let id = message?.id {
//            ConversationViewModel.shared.addPlayer(MessagePlayer(player: self.player, messageId: message.id))
//            //                    }
//        }
        
        //            HStack(alignment: .top, spacing: 9) {
        //
        ////            KFImage(URL(string: self.profileImageUrl))
        ////                .resizable()
        ////                .scaledToFill()
        ////                .frame(width: 30, height: 30)
        ////                .clipShape(Circle())
        ////
        ////            VStack(alignment: .leading, spacing: 2) {
        ////                Text(name)
        ////                    .font(.system(size: 14, weight: .semibold))
        ////                + Text(" • \(date.getFormattedDate())")
        ////                    .font(.system(size: 12, weight: .regular))
        ////                    .foregroundColor(.mainGray)
        //            Spacer()
        //
        //                Button {
        //                    if !audioPlayer.isPlaying {
        //                        audioPlayer.hasFinished ? audioPlayer.startPlayback(audio: self.audioURL) : audioPlayer.resume()
        //                    } else {
        //                        audioPlayer.pause()
        //                    }
        //                } label: {
        //
        //
        //                        Image(systemName: audioPlayer.isPlaying ?
        //                              "pause.fill" : "play.fill")
        //                            .resizable()
        //                            .scaledToFit()
        //                            .frame(width: 80, height: 80)
        //                            .foregroundColor(.white)
        //                            .padding(.leading, audioPlayer.isPlaying ? 0 : 10)
        //
        //
        ////                }
        //            }
        //
        //            Spacer()
        //        }
        //        .frame(width: SCREEN_WIDTH - 10, height: SCREEN_WIDTH * 16/18)
        //        .overlay(
        //            MessageInfoView(date: message.timestamp.dateValue(), profileImage: message.userProfileImageUrl, name: message.username)
        //                .padding(.horizontal, 12)
        //                .padding(.vertical, 26), alignment: .bottomLeading)
        //        }
        ////        .frame(width: SCREEN_WIDTH - 10, height: SCREEN_WIDTH * 16/18)
        //        .background(Color.mainBlue)
        //        .cornerRadius(12)
        //        .overlay(
        //            ZStack {
        //                if isSaved {
        //                    Button {
        //                        showAlert = true
        //                    } label: {
        //                        ZStack {
        //
        //                            Circle()
        //                                .frame(width: 24, height: 24)
        //                                .foregroundColor(.point3AlphaSystemBlack)
        //
        //                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
        //                                .resizable()
        //                                .scaledToFit()
        //                                .foregroundColor(.systemWhite)
        //                                .frame(width: 13, height: 13)
        //                        }
        //                        .padding(.horizontal, 8)
        //                    }.alert(isPresented: $showAlert) {
        //                        savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
        //                            self.isSaved = isSaved
        //                        })
        //                    }
        //                }
        //            }
        //            ,alignment: .topTrailing)
        //        .padding(.vertical, 8)
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
    
    func togglePlay() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
}

//struct AudioCell_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioCell()
//    }
//}
