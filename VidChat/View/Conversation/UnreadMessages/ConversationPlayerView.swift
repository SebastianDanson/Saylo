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
    @State var isSaved = false
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
           
            if viewModel.messages.count > viewModel.index && viewModel.index >= 0 {
                
                
                                
                VStack(spacing: 6) {
                    
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
                            .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                            .background(Color.alternateMainBlue)
                            .cornerRadius(14, corners: [.topLeft, .topRight])

                            
                        } else if viewModel.messages[viewModel.index].type == .Photo {
                            
                            if let url = viewModel.messages[viewModel.index].url {
                                KFImage(URL(string: url))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: SCREEN_WIDTH, maxWidth: SCREEN_WIDTH, minHeight: 0, maxHeight: MESSAGE_HEIGHT)
                                    .cornerRadius(14, corners: [.topLeft, .topRight])
                                    .clipped()
                            } else if let image = viewModel.messages[viewModel.index].image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: SCREEN_WIDTH, maxWidth: SCREEN_WIDTH, minHeight: 0, maxHeight: MESSAGE_HEIGHT)
                                    .cornerRadius(14, corners: [.topLeft, .topRight])
                                    .clipped()
                            }
                        }
                        
                        VStack {
                            
                            HStack {
                                
                                Button {
                                    MainViewModel.shared.selectedView = .Video
                                } label: {
                                    Image("x")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .padding(.leading)
                                        .padding(.top, 20)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                    .zIndex(3)
                    .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
                    .onTapGesture(perform: {
                        withAnimation {
                            viewModel.toggleIsPlaying()
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
                                            
                                            AddedReactionsContainerView(reactions: $viewModel.messages[viewModel.index].reactions)
                                                .padding(.leading, 16)
                                                .padding(.bottom, viewModel.isPlayable() && !viewModel.showPlaybackControls ? 116 :
                                                            viewModel.showPlaybackControls ? 32 : 76)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 8) {
                                            
                                            
                                            if showReactions {
                                                ReactionView(messageId: viewModel.messages[viewModel.index].id, reactions: $viewModel.messages[viewModel.index].reactions, showReactions: $showReactions)
                                                    .transition(.scale)
                                            } else {
                                                
                                                Button {
                                                    withAnimation {
                                                        MainViewModel.shared.selectedMessage = ConversationViewModel.shared.messages[ConversationViewModel.shared.index]
                                                    }
                                                    ConversationViewModel.shared.toggleIsPlaying()
                                                } label: {
                                                    
                                                    Image(systemName: "ellipsis")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.white)
                                                        .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                                }
                                            }
                                            
                                            
                                            Button {
                                                withAnimation(.linear(duration: 0.2)) {
                                                    showReactions.toggle()
                                                    ConversationViewModel.shared.isShowingReactions.toggle()
                                                }
                                            } label: {
                                                
                                                ZStack {
                                                    
                                                    if showReactions {
                                                        
                                                        Circle()
                                                            .frame(width: 46, height: 46)
                                                            .foregroundColor(.point3AlphaSystemBlack)
                                                    }
                                                    
                                                    
                                                    Image(systemName: "face.smiling")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 32, height: 32)
                                                        .foregroundColor(.white)
                                                }                                                
                                            }
                                            
                                            if isSaved {
                                                
                                                Button {
                                                    showAlert = true
                                                } label: {
                                                    
                                                    ZStack {
                                                        
                                                        Circle()
                                                            .frame(width: 36, height: 36)
                                                            .foregroundColor(viewModel.messages[viewModel.index].savedByCurrentUser ? (viewModel.messages[viewModel.index].type == .Video ? .mainBlue : .white) : .lightGray)
                                                        
                                                        Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash.fill" : "bookmark.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(viewModel.messages[viewModel.index].type == .Video || !viewModel.messages[viewModel.index].savedByCurrentUser ? .white : .mainBlue)
                                                            .frame(width: 18, height: 18)
                                                    }
                                                    
                                                }.alert(isPresented: $showAlert) {
                                                    savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == viewModel.messages[viewModel.index].id}), completion: { isSaved in
                                                        withAnimation {
                                                            self.isSaved = isSaved
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                        .padding(.trailing, 18)
                                        .padding(.bottom, 36)
                                    }
                                }
                                .padding(.bottom, viewModel.showPlaybackControls ? 60 : 0)
                                
                            
                            VStack {
                                
                                Spacer()
                                
                                if !viewModel.showPlaybackControls {
                                    HStack {
                                        
                                        if !viewModel.messages[viewModel.index].isForTakingVideo {                                            
                                            MessageInfoView(date: viewModel.messages[viewModel.index].timestamp.dateValue(),
                                                                                  profileImage: viewModel.messages[viewModel.index].userProfileImage,
                                                                                  name: viewModel.messages[viewModel.index].username,
                                                                                  showTwoTimeSpeed: viewModel.isPlayable())
                                                .padding(.bottom, -8)
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                }
                                
                                
                                if viewModel.showPlaybackControls {
                                    PlaybackControls(showPlaybackControls: $viewModel.showPlaybackControls, sliderValue: $sliderValue)
                                }
                                
                                PlaybackSlider(sliderValue: $sliderValue, isPlaying: $viewModel.isPlaying, showPlaybackControls: $viewModel.showPlaybackControls)
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                            }
                            .padding(.horizontal, 12)
                        }
                        
                        
                    )
                    .padding(.top, TOP_PADDING)

                    
//
//                    UnreadMessagesScrollView()
//                        .padding(.top, 4)
//                        .zIndex(10)
                    
                    Spacer()
                    
                }
                
            }
            
            Spacer()
        }
        .onChange(of: viewModel.index, perform: { _ in
            print("")
            sliderValue = 0
        })
        
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
