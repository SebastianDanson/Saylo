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
    
    init() {
        
        //        var playerItems = [AVPlayerItem]()
        //        var dates = [Date]()
        //
        //        viewModel.messages.forEach({
        //            if ($0.type == .Video || $0.type == .Audio), let urlString = $0.url, let url = URL(string: urlString) {
        //                let playerItem = AVPlayerItem(asset: AVAsset(url: url))
        //                playerItems.append(playerItem)
        //                dates.append($0.timestamp.dateValue())
        //            }
        //        })
        //
        //        let player = AVQueuePlayer(items: playerItems)
        //        player.automaticallyWaitsToMinimizeStalling = false
        //        viewModel.player = player
        //        //        viewModel.player.play()
        //        viewModel.playerItems = playerItems
    }
    
    
    var body: some View {
        
        let messageInfoView = MessageInfoView(date: viewModel.messages[viewModel.index].timestamp.dateValue(),
                                              profileImage: viewModel.messages[viewModel.index].userProfileImage,
                                              name: viewModel.messages[viewModel.index].username)
        
        
        ZStack(alignment: .top) {
            
            VStack {
                
                ZStack {
                    
                    if viewModel.isPlayable(), let urlString = viewModel.messages[viewModel.index].url, let url = URL(string: urlString) {
                        
                        UnreadMessagePlayerView(url: url)
                            .background(viewModel.messages[viewModel.index].type == .Audio ? Color.mainBlue : Color.systemBlack)
                            .cornerRadius(22)
                            .overlay(
                                ZStack {
                                    if viewModel.messages[viewModel.index].type == .Audio {
                                        Image(systemName: "waveform")
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(.white)
                                            .scaledToFill()
                                            .padding(.top, 8)
                                    }
                                }
                            )
                        
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
                .overlay(
                    
                    VStack {
                        HStack {
                            
                            VStack {
                                Button(action: {
                                    withAnimation(.linear(duration: 0.2)) {
                                        viewModel.removePlayerView()
                                    }
                                }, label: {
                                    CameraOptionView(image: Image("x"), imageDimension: 17, circleDimension: 32, topPadding: 3)
                                        .padding(.horizontal, 8)
                                })
                                
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        HStack {
                            
                            messageInfoView
                                .padding(.horizontal, 16)
                                .padding(.vertical, viewModel.isPlayable() ? 36 : 20)
                            
                            Spacer()
                        }
                        //                .padding(.horizontal, 16)
                        //                .padding(.bottom, viewModel.isPlayable() ? 40 : 24)
                        
                    }
                        .frame(width: CAMERA_SMALL_WIDTH, height: CAMERA_SMALL_HEIGHT)
                        .cornerRadius(20)
                    
                )
                
                UnreadMessagesScrollView().padding(.top, 4)
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

