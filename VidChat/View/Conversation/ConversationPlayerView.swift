//
//  ConversationPlayerView.swift
//  VidChat
//
//  Created by Student on 2021-12-13.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct ConversationPlayerView: View {
    
    @ObservedObject var viewModel = ConversationPlayerViewModel.shared
    @ObservedObject var conversationViewModel = ConversationViewModel.shared
    
    private var token: NSKeyValueObservation?
    private var textMessages = [Message]()
    
    init() {
        
        var playerItems = [AVPlayerItem]()
        var dates = [Date]()
        
        ConversationViewModel.shared.messages.forEach({
            if ($0.type == .Video || $0.type == .Audio), let urlString = $0.url, let url = URL(string: urlString) {
                let playerItem = AVPlayerItem(asset: AVAsset(url: url))
                playerItems.append(playerItem)
                dates.append($0.timestamp.dateValue())
            }
        })
        
        let player = AVQueuePlayer(items: playerItems)
        player.automaticallyWaitsToMinimizeStalling = false
        viewModel.player = player
        viewModel.player.play()
        viewModel.playerItems = playerItems
    }
    
    
    var body: some View {
        
        let messageInfoView = MessageInfoView(date: conversationViewModel.messages[viewModel.index].timestamp.dateValue(),
                                              profileImage: conversationViewModel.messages[viewModel.index].userProfileImageUrl,
                                              name: conversationViewModel.messages[viewModel.index].username)
        
        
        ZStack(alignment: .top) {
            
            ZStack {
                if conversationViewModel.messages[viewModel.index].type == .Video || conversationViewModel.messages[viewModel.index].type == .Audio {
                    
                    PlayerQueueView()
                        .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
                        .background(conversationViewModel.messages[viewModel.index].type == .Audio ? Color.mainBlue : Color.systemBlack)
                        .overlay(
                            ZStack {
                                if conversationViewModel.messages[viewModel.index].type == .Audio {
                                    Image(systemName: "waveform")
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.white)
                                        .scaledToFill()
                                        .padding(.top, 8)
                                }
                            }
                        )
                    
                } else if conversationViewModel.messages[viewModel.index].type == .Text, let text = conversationViewModel.messages[viewModel.index].text {
                    ZStack {
                        Text(text)
                            .foregroundColor(.white)
                            .font(.system(size: 28, weight: .bold))
                            .padding()
                        
                    }
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
                    .background(Color.mainBlue)
                    
                } else if conversationViewModel.messages[viewModel.index].type == .Photo {
                    
                    if let url = conversationViewModel.messages[viewModel.index].url {
                        KFImage(URL(string: url))
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: SCREEN_WIDTH - 10, maxWidth: SCREEN_WIDTH - 10, minHeight: 0, maxHeight: SCREEN_WIDTH * 16/9)
                            .cornerRadius(12)
                            .clipped()
                    } else if let image = conversationViewModel.messages[viewModel.index].image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: SCREEN_WIDTH - 10, maxWidth: SCREEN_WIDTH - 10, minHeight: 0, maxHeight: SCREEN_WIDTH * 16/9)
                            .cornerRadius(12)
                            .clipped()
                    }
                }
            }.padding(.top, TOP_PADDING)
            
            VStack {
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                    .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
                    .padding(.top, TOP_PADDING - 10)
                
                Spacer()
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
                        CameraOptionView(image: Image(systemName: "chevron.down"), imageDimension: 17, circleDimension: 32, topPadding: 3)
                            .padding(.horizontal, 8)
                            .padding(.top, -28)
                    })
                        
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    
                    messageInfoView
                        .padding(.horizontal, 16)
                        .padding(.vertical, viewModel.isPlayable() ? 64 : 48)
                    
                    Spacer()
                }
//                .padding(.horizontal, 16)
//                .padding(.bottom, viewModel.isPlayable() ? 40 : 24)
                
            }
            .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
        )
        
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color.black)
        .offset(viewModel.dragOffset)
        .gesture(viewModel.isPlayable() ? nil : DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
            viewModel.dragOffset.height = max(0, gesture.translation.height)
        }
                    .onEnded({ (value) in
            
            if viewModel.dragOffset.height == 0  {
                
                let xLoc = value.location.x
                
                if xLoc > SCREEN_WIDTH/2 {
                    viewModel.handleShowNextMessage(wasInterrupted: true)
                } else  {
                    viewModel.handleShowPrevMessage()
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

