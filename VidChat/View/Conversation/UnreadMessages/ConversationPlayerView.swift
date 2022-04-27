//
//  ConversationPlayerView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-02-28.
//


import SwiftUI
import AVFoundation
import Kingfisher

struct ConversationPlayerView: View {
    
    @ObservedObject var viewModel = ConversationViewModel.shared
    @ObservedObject var mainViewModel = MainViewModel.shared
    
    @State var isFirstReplyOption = true
    @State var showReactions = false
    @State var showAlert = false
    @State var sliderValue = 0.0
    
    //    @State var showPlayerViewTutorial: Bool
    
    //    private var hasSeenPlayerViewTutorial: Bool
    private var token: NSKeyValueObservation?
    private var textMessages = [Message]()
    
    //    init() {
    //
    //        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
    //        hasSeenPlayerViewTutorial = defaults?.bool(forKey: "hasSeenPlayerViewTutorial") ?? false
    //        self._showPlayerViewTutorial = State(initialValue: !hasSeenPlayerViewTutorial)
    //        defaults?.set(true, forKey: "hasSeenPlayerViewTutorial")
    //    }
    
    //    init() {
    //
    //    }
    
    var body: some View {
        
        VStack {
            
            let messages = viewModel.showSavedPosts ? viewModel.savedMessages : viewModel.messages
            let index = viewModel.index
            
            if messages.count > index && index >= 0 {
                
                VStack(spacing: 6) {
                    
                    ZStack {
                        
                        if viewModel.isPlayable(), let urlString = messages[index].url, let url = URL(string: urlString) {
                            
                            if viewModel.hasChanged {
                                UnreadMessagePlayerView(url: url, isVideo: messages[index].type == .Video)
                            } else {
                                UnreadMessagePlayerView(url: url, isVideo: messages[index].type == .Video)
                            }
                            
                        } else if messages[index].type == .Text, let text = messages[index].text {
                            
                            ZStack {
                                
                                Text(text)
                                    .foregroundColor(.white)
                                    .font(.system(size: 28, weight: .bold))
                                    .padding()
                                
                            }
                            .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                            .background(Color.alternateMainBlue)
                            .cornerRadius(14)
                            
                            
                        } else if messages[index].type == .Photo {
                            
                            if let url = messages[index].url {
                                KFImage(URL(string: url))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: SCREEN_WIDTH, maxWidth: SCREEN_WIDTH, minHeight: 0, maxHeight: MESSAGE_HEIGHT)
                                    .cornerRadius(14)
                                    .clipped()
                                    .background(Color.black)
                            } else if let image = messages[index].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: SCREEN_WIDTH, maxWidth: SCREEN_WIDTH, minHeight: 0, maxHeight: MESSAGE_HEIGHT)
                                    .cornerRadius(14)
                                    .clipped()
                                    .background(Color.black)
                            }
                        }
                        
                        
                    }
                    .zIndex(3)
                    .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                    .onTapGesture(perform: {
                        withAnimation {
                            viewModel.toggleIsPlaying()
                            if showReactions {
                                showReactions = false
                            }
                        }
                    })
                    .overlay(
                        
                        ZStack {
                            
                            
                            //                            if !viewModel.showPlaybackControls {
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack(alignment: .bottom) {
                                    
                                    VStack {
                                        
                                        Spacer()
                                        
                                        if !viewModel.showSavedPosts {
                                            
                                            AddedReactionsContainerView(reactions: $viewModel.messages[viewModel.index].reactions)
                                                .padding(.leading, 16)
                                                .padding(.bottom, viewModel.isPlayable() && !viewModel.showPlaybackControls ? 116 :
                                                            viewModel.showPlaybackControls ? 32 : 76)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 0) {
                                        
                                        
                                        if showReactions {
                                            if !viewModel.showSavedPosts {
                                                
                                                ReactionView(messageId: messages[index].id,
                                                             reactions: $viewModel.messages[viewModel.index].reactions,
                                                             showReactions: $showReactions)
                                                .transition(.scale)
                                                .padding(.bottom, 8)
                                            }
                                        } else {
                                            
                                            
                                            Button {
                                                removeView()
                                            } label: {
                                                
                                                Image(systemName: "arrowshape.turn.up.left")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 28, height: 28)
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                                    .padding(.bottom, IS_SMALL_WIDTH ? 22 : 27)
                                            }
                                            .alert(isPresented: $showAlert) {
                                                savedPostAlert(mesageIndex: messages.firstIndex(where: {$0.id == messages[viewModel.index].id}), completion: { isSaved in
                                                    
                                                })
                                            }
                                            
                                            Button {
                                                if messages[index].isSaved {
                                                    showAlert = true
                                                } else {
                                                    ConversationViewModel.shared.updateIsSaved(atIndex: index)
                                                }
                                            } label: {
                                                
                                                Image(systemName: messages[index].isSaved ? "bookmark.fill" : "bookmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 28)
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                                    .padding(.bottom, IS_SMALL_WIDTH ? 22 : 27)
                                            }
                                            .alert(isPresented: $showAlert) {
                                                savedPostAlert(mesageIndex: messages.firstIndex(where: {$0.id == messages[viewModel.index].id}), completion: { isSaved in
                                                    
                                                })
                                            }
                                            
                                            
                                            
                                        }
                                        
                                        
                                        if !viewModel.showSavedPosts {
                                            Button {
                                                withAnimation(.linear(duration: 0.2)) {
                                                    showReactions.toggle()
                                                    ConversationViewModel.shared.isShowingReactions.toggle()
                                                }
                                            } label: {
                                                
                                                ZStack {
                                                    
                                                    if showReactions {
                                                        Circle()
                                                            .frame(width: 38, height: 38)
                                                            .foregroundColor(.point3AlphaSystemBlack)
                                                    }
                                                    
                                                    
                                                    Image(systemName: "face.smiling")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 26, height: 28)
                                                        .foregroundColor(.white)
                                                        .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                                }
                                                .padding(.bottom, IS_SMALL_WIDTH ? 12 : 16)
                                            }
                                        }
                                        
                                        if !showReactions {
                                            
                                            Button {
                                                withAnimation {
                                                    MainViewModel.shared.selectedMessage = messages[index]
                                                }
                                                ConversationViewModel.shared.toggleIsPlaying()
                                            } label: {
                                                
                                                Image(systemName: "ellipsis")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 19, height: 28)
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                            }
                                        }
                                        
                                    }
                                    .padding(.trailing, 18)
                                    .padding(.bottom, IS_SMALL_WIDTH ? 28 : 34)
                                }
                            }
                            .padding(.bottom, viewModel.showPlaybackControls ? 60 : 0)
                            
                            
                            VStack {
                                
                                Spacer()
                                
                                if !viewModel.showPlaybackControls {
                                    
                                    HStack {
                                        
                                        if !messages[index].isForTakingVideo {
                                            MessageInfoView(date: messages[index].timestamp.dateValue(),
                                                            profileImage: messages[index].userProfileImage,
                                                            name: messages[index].username,
                                                            showTwoTimeSpeed: viewModel.isPlayable())
                                            .padding(.bottom, -8)
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                }
                                
                                
                                if viewModel.showPlaybackControls {
                                    
                                    VStack {
                                        
                                        HStack {
                                            Spacer()
                                            Text("\(getWatchedVideoLength())/\(getTotalVideoLength())")
                                                .foregroundColor(.white)
                                                .font(Font.system(size: 14, weight: .medium, design: .rounded))
                                                .frame(width: 84, height: 28)
                                                .background(Color.fadedBlack)
                                                .clipShape(Capsule())
                                                .padding(.bottom, 10)
                                            Spacer()
                                        }
                                        
                                        PlaybackControls(showPlaybackControls: $viewModel.showPlaybackControls, sliderValue: $sliderValue)
                                    }
                                }
                                
                                PlaybackSlider(sliderValue: $sliderValue, isPlaying: $viewModel.isPlaying, showPlaybackControls: $viewModel.showPlaybackControls)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        
                    )
                    .padding(.top, TOP_PADDING )
                    
                    
                    //
                    //                    UnreadMessagesScrollView()
                    //                        .padding(.top, 4)
                    //                        .zIndex(10)
                    
                    Spacer()
                    
                }
                
            }
            
            Spacer()
        }
        .ignoresSafeArea()
        .overlay(
            
            ZStack {
                if viewModel.showSavedPosts, viewModel.savedMessages.count == 0 {
                    
                    VStack(spacing: 0) {
                        
                        Text("No messages saved in this chat")
                            .foregroundColor(.white)
                            .font(.system(size: IS_SMALL_PHONE ? 21 : 24, weight: .semibold, design: .rounded))
                            .padding(.bottom, 4)
                        
                        Text("Tap and hold on a message to save it!")
                            .foregroundColor(.white)
                            .font(.system(size: IS_SMALL_PHONE ? 16 : 18, weight: .regular, design: .rounded))
                            .padding(.bottom, 10)
                    }
                    .frame(width: SCREEN_WIDTH - 12, height: 150)
                    .background(Color.mainBlue)
                    .cornerRadius(8)
                }
                
                VStack {
                    
                    HStack {
                        
                        Button {
                            removeView()
                        } label: {
                            Image("x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: IS_SMALL_WIDTH ? 24 : 28, height: IS_SMALL_WIDTH ? 24 : 28)
                                .shadow(color: Color(white: 0, opacity: 0.2), radius: 4, x: 0, y: 4)
                                .padding(.leading, 12)
                                .padding(.top, 12 + TOP_PADDING)
                        }
                        
                        Spacer()
                        
                        
                    }
                    
                    Spacer()
                }
            }
        )
        .background(Color.black)
        .onChange(of: viewModel.index, perform: { _ in
            print("")
            sliderValue = 0
        })
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
    }
    
    func getTotalVideoLength() -> String {
        return viewModel.videoLength.minuteSecond
    }
    
    func getWatchedVideoLength() -> String {
        return (sliderValue * viewModel.videoLength).minuteSecond
    }
    
    func removeView() {
        MainViewModel.shared.selectedView = .Video
        ConversationViewModel.shared.showSavedPosts = false
        ConversationViewModel.shared.savedMessages.removeAll()
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
