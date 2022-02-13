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
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    
    @State var isFirstReplyOption = true
    @State var showPlayerViewTutorial: Bool
    
    private var hasSeenPlayerViewTutorial: Bool
    private var token: NSKeyValueObservation?
    private var textMessages = [Message]()
    
    init() {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        hasSeenPlayerViewTutorial = defaults?.bool(forKey: "hasSeenPlayerViewTutorial") ?? false
        self._showPlayerViewTutorial = State(initialValue: !hasSeenPlayerViewTutorial)
        defaults?.set(true, forKey: "hasSeenPlayerViewTutorial")
    }
    
    var body: some View {
        
        ZStack {
            
            if viewModel.messages.count > viewModel.index {
                
                let messageInfoView = MessageInfoView(date: viewModel.messages[viewModel.index].timestamp.dateValue(),
                                                      profileImage: viewModel.messages[viewModel.index].userProfileImage,
                                                      name: viewModel.messages[viewModel.index].username,
                                                      showTwoTimeSpeed: viewModel.isPlayable())
                
                
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
                            } else if viewModel.messages[viewModel.index].isForTakingVideo {
                                
                                CameraViewModel.shared.cameraView
                                    .frame(width: cameraViewModel.showFullCameraView ? SCREEN_WIDTH : CAMERA_SMALL_WIDTH,
                                           height: cameraViewModel.showFullCameraView ? SCREEN_HEIGHT : CAMERA_SMALL_HEIGHT)
                                    .overlay(
                                        
                                        
                                        VStack(spacing: 16) {
                                            
                                            Spacer()
                                            
                                            if cameraViewModel.videoUrl == nil && cameraViewModel.photo == nil {
                                                
                                                if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == viewModel.messages[viewModel.index].chatId}) {
                                                    
                                                    if !cameraViewModel.showFullCameraView {
                                                        
                                                        Text("Reply to \(chat.name)?")
                                                            .font(.system(size: 24, weight: .semibold))
                                                            .foregroundColor(.white)
                                                    }
                                                    
                                                    
                                                    Button {
                                                        withAnimation(.linear(duration: 0.2)) {
                                                            CameraViewModel.shared.cameraView.setPreviewLayerFullFrame()
                                                            cameraViewModel.showFullCameraView = true
                                                            cameraViewModel.handleTap()
                                                            
                                                            ConversationViewModel.shared.selectedChat = chat
                                                        }
                                                    } label: {
                                                        CameraCircle()
                                                            .padding(.bottom, cameraViewModel.showFullCameraView ?
                                                                     (SCREEN_RATIO > 2 ? 120 : 32) : 0)
                                                    }
                                                }
                                            }
                                            
                                        }.padding(.bottom, 20)
                                    )
                            }
                            
                        }
                        .zIndex(3)
                        .overlay(
                            
                            ZStack {
                                
                                VStack {
                                    
                                    Spacer()
                                    
                                    HStack {
                                        
                                        if !viewModel.messages[viewModel.index].isForTakingVideo {
                                            
                                            messageInfoView
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, viewModel.isPlayable() ? 36 : 20)
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                }
                                
                                if showPlayerViewTutorial {
                                    MessageNavigationInstructionsView()
                                }
                                
                            }
                                .frame(width: cameraViewModel.showFullCameraView ? SCREEN_WIDTH : CAMERA_SMALL_WIDTH,
                                       height: cameraViewModel.showFullCameraView ? SCREEN_HEIGHT : CAMERA_SMALL_HEIGHT)
                                .cornerRadius(24)
                            
                        )
                        
                        //                HStack(alignment: .center) {
                        
                        if !cameraViewModel.showFullCameraView {
                            ZStack {
                                
                                UnreadMessagesScrollView()
                                    .padding(.top, 4)
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        //                                withAnimation(.linear(duration: 0.1)) {
                                        viewModel.removePlayerView()
                                        cameraViewModel.showFullCameraView = false
                                        //                                }
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
                        
                        if cameraViewModel.showFullCameraView {
                            Spacer()
                        }
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
                            
                            if viewModel.messages[viewModel.index].isForTakingVideo && isFirstReplyOption && !hasSeenPlayerViewTutorial {
                                self.showPlayerViewTutorial = true
                                self.isFirstReplyOption = false
                                self.stopShowingTutorialView()
                            }
                            
                            
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
                .onAppear {
                    if !hasSeenPlayerViewTutorial {
                        self.stopShowingTutorialView()
                    }
                }
                .onDisappear {
                    viewModel.messages.removeAll()
                }
            } else {
                
                //No messages so don't show this unread messages pop up
                ZStack {
                    
                }.onAppear {
                    ConversationGridViewModel.shared.hasUnreadMessages = false
                }
            }
        }
    }
    
    func stopShowingTutorialView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showPlayerViewTutorial = false
        }
    }
}


struct MessageNavigationInstructionsView: View {
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack {
                
                Image(systemName: "hand.tap.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                
                Text("Previous")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }.frame(width: 120)
            
            Spacer()
            
            Line()
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 1)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack {
                
                Image(systemName: "hand.tap.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                
                Text("Next")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }.frame(width: 120)
            
            Spacer()
            
        }.background(Color(white: 0, opacity: 0.3))
        
        
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
