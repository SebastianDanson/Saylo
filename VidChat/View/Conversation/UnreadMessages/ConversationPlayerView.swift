//
//  ConversationPlayerView.swift
//  Saylo
//
//  Created by Student on 2021-12-13.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct ConversationPlayerView: View {
    
    @ObservedObject var viewModel = ConversationPlayerViewModel.shared
    private var token: NSKeyValueObservation?
    private var textMessages = [Message]()
    
    
    var body: some View {
        
        let messageInfoView = MessageInfoView(date: viewModel.messages[viewModel.index].timestamp.dateValue(),
                                              profileImage: viewModel.messages[viewModel.index].userProfileImage,
                                              name: viewModel.messages[viewModel.index].username)
        
        
        ZStack(alignment: .bottom) {
            
            VStack {
                
                Spacer()
                
                ZStack {
                    
                    if viewModel.isPlayable(), let urlString = viewModel.messages[viewModel.index].url, let url = URL(string: urlString) {
                        
                        
                        if viewModel.hasChanged {
                            UnreadMessagePlayerView(url: url, isVideo: viewModel.messages[viewModel.index].type == .Video)
                        } else {
                            UnreadMessagePlayerView(url: url, isVideo: viewModel.messages[viewModel.index].type == .Video)
                        }
                       
                        
                    } else if viewModel.messages[viewModel.index].type == .Text, let text = viewModel.messages[viewModel.index].text {
                        
                        ZStack {
                            Text(text)
                                .foregroundColor(.white)
                                .font(.system(size: 28, weight: .bold))
                                .padding()
                            
                        }
                        .frame(width: CAMERA_SMALL_WIDTH, height: CAMERA_SMALL_HEIGHT)
                        .background(Color.mainBlue)
                        .cornerRadius(20)
                        
                        
                    } else if viewModel.messages[viewModel.index].type == .Photo {
                        
                        if let url = viewModel.messages[viewModel.index].url {
                            KFImage(URL(string: url))
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: CAMERA_SMALL_WIDTH, maxWidth: CAMERA_SMALL_WIDTH, minHeight: 0, maxHeight: CAMERA_SMALL_HEIGHT)
                                .cornerRadius(20)
                                .clipped()
                        } else if let image = viewModel.messages[viewModel.index].image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: CAMERA_SMALL_WIDTH, maxWidth: CAMERA_SMALL_WIDTH, minHeight: 0, maxHeight: CAMERA_SMALL_HEIGHT)
                                .cornerRadius(20)
                                .clipped()
                        }
                    }
                    
                }
                .zIndex(3)
                .overlay(
                    VStack {
                
                        Spacer()
                        
                        HStack {
                            
                            messageInfoView
                                .padding(.horizontal, 16)
                                .padding(.vertical, viewModel.isPlayable() ? 36 : 20)
                            
                            Spacer()
                            
                        }
                    }
                        .frame(width: CAMERA_SMALL_WIDTH, height: CAMERA_SMALL_HEIGHT)
                        .cornerRadius(24)
                    
                )
            
//                HStack(alignment: .center) {
                    
                ZStack {
                    
                    UnreadMessagesScrollView()
                        .padding(.top, 4)
                                        
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.linear(duration: 0.2)) {
                                viewModel.removePlayerView()
                            }
                        }, label: {
                            
                            ZStack {
                                
                                Circle()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.lightGray)
                                
                                Image("x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                
                            }.padding(.trailing, 20)
                            
                        })
                    }
                }.padding(.bottom, BOTTOM_PADDING + 16)

            }
        }
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color(white: 0, opacity: 0.8))
        .offset(viewModel.dragOffset)
        .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
            viewModel.dragOffset.height = max(0, gesture.translation.height)
        }
                    .onEnded({ (value) in
            
            if viewModel.dragOffset.height == 0  {
                
                let xLoc = value.location.x
                
                if xLoc > SCREEN_WIDTH/2 {
                    viewModel.showNextMessage()
                } else  {
                    viewModel.showPreviousMessage()
                }
            }
            
            withAnimation(.linear(duration: 0.2)) {
                
                if viewModel.dragOffset.height > SCREEN_HEIGHT / 4 {
                    viewModel.removePlayerView()
                } else {
                    viewModel.dragOffset.height = 0
                }
            }
            
        }))
        
    }
}

