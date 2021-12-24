//
//  VideoCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

//TODO fix issue when you close camera and u see the whit background of text cell i.e have textcell on screen and open and close camera

struct VideoCell: View {
    
    @State var message: Message
    @State var showReaction = false
    
    let videoPlayerView: VideoPlayerView
    
    init(message: Message) {
        self.message = message
        self.videoPlayerView = VideoPlayerView(url: URL(string: message.url!)!, id: message.id, isSaved: message.isSaved, showName: true,
                                                date: message.timestamp.dateValue())
    }
    var body: some View {
        
        ZStack {
            
            videoPlayerView
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            
                            if showReaction {
                                ReactionView()
                                    .transition(.scale)
                            }
                            
                            Button {
                                withAnimation(.linear(duration: 0.2)) {
                                    showReaction.toggle()
                                }
                            } label: {
                                ZStack {
                                    
                                    if showReaction {
                                        Circle()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(Color(white: 0, opacity: 0.3))
//                                            .transition(.scale)
                                    }
                                    
                                    Image(systemName: "face.smiling")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.white)
                                }
                                
                                
                            }
                        } .padding(.trailing, 18)
                            .padding(.bottom, 36)
                    }
                }
            }
//        }
    }
}

struct ReactionView: View {
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 27, height: 27)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .padding(.top, 12)
            
            Image(systemName: "hand.thumbsup.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 27, height: 27)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
            
            Image(systemName: "hand.thumbsdown.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 27, height: 27)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
            
            Image("ExclamationMark")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 28, height: 32)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
            
            Image("Haha")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
   
        }
        .background(Color(white: 0, opacity: 0.3))
        .clipShape(Capsule())
    }
}
