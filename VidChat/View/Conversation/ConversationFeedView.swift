//
//  ConversationFeedView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-21.
//

import SwiftUI
import AVFoundation

struct ViewOffsetsKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct ConversationFeedView: View {
    
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var middleItemNo = -1
    @State var updatePreference = false
    
    @StateObject private var viewModel = ConversationViewModel.shared
    let showSavedPosts: Bool
    
    var body: some View {
        
        ScrollView {
            
            ScrollViewReader { reader in
                
                VStack(spacing: 0) {
                    
                    ForEach(showSavedPosts ? Array(viewModel.savedMessages.enumerated()) : Array(viewModel.messages.enumerated()), id: \.1.id) { i, element in
                        MessageCell(message: getMessages()[i])
                            .transition(.move(edge: .bottom))
                            .offset(x: 0, y: -28)
                            .background(
                                getMessages()[i].type != .Text ? GeometryReader { geo in
                                    Color.systemWhite.preference(
                                        key: ViewOffsetsKey.self,
                                        value: [i: geo.frame(in: .named("scrollView")).origin.y]) } : nil)
                            .onAppear {
                                
                                if let chat = viewModel.chat {
                                    if i == chat.lastReadMessageIndex {
                                        reader.scrollTo(getMessages()[i].id, anchor: .center)
                                    }
                                }
                                
                            }
                    }
                }.flippedUpsideDown()
                    .onPreferenceChange( ViewOffsetsKey.self, perform: { prefs in
                        
                        guard updatePreference else { return }
                        
                        print(middleItemNo)
                        let prevMiddleItemNo = middleItemNo
                        middleItemNo = prefs.first(where: { $1 > 40 && $1 < 90 })?.key ?? -1
                        
                        //                        viewModel.showKeyboard = false
                        //                        UIApplication.shared.endEditing()
                        
                        if middleItemNo >= 0 {
                            viewModel.isPlaying = true
                            if prevMiddleItemNo != middleItemNo {
                                viewModel.currentPlayer?.pause()
                                viewModel.currentPlayer = viewModel.players.first(where: {$0.messageId == getMessages()[middleItemNo].id})?.player
                                
                                viewModel.currentPlayer?.play()
                                
                                withAnimation {
                                    reader.scrollTo(getMessages()[middleItemNo].id, anchor: .center)
                                }
                            }
                        } else {
                            viewModel.isPlaying = false
                            viewModel.currentPlayer?.pause()
                        }
                    }) .onChange(of: viewModel.index, perform: { newValue in
                        print("CGANGED", middleItemNo)
                        middleItemNo += 1
                        
                        if middleItemNo < 1 || middleItemNo >= getMessages().count {return}
                        
                        updatePreference = false
                        
                        let message = getMessages()[middleItemNo]
                        
                        if message.type == .Text {
                            withAnimation {
                                reader.scrollTo(message.id, anchor: .center)
                            }
                        } else {
                            reader.scrollTo(message.id, anchor: .center)
                        }
                        
                        
                        viewModel.currentPlayer?.pause()
                        
                        viewModel.currentPlayer = viewModel.players.first(where: {$0.messageId == getMessages()[middleItemNo].id})?.player
                        viewModel.currentPlayer?.play()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            updatePreference = true
                        }
                        
                    })
                    .onChange(of: viewModel.scrollToBottom) { newValue in
                        if let last = getMessages().last {
                            reader.scrollTo(last.id, anchor: .bottom)
                        }
                    }
            }
            .padding(.top, !viewModel.showKeyboard && !viewModel.showPhotos ? 72 + BOTTOM_PADDING : -20)
            .padding(.bottom, 100)
            
        }
        
        
        
        //TODO if the last message is a view (aka the fist cell u see), make sure it starts playing right away
        
        //TODO don't scroll if you're high up and ur not the one sending
        //AKA ur watching an older vid and ur buddy send u don't wanna scroll
        // if !isFirstLoad {
        //}
        
        .flippedUpsideDown()
        //        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color.systemWhite)
        .coordinateSpace(name: "scrollView")
        .onAppear {
            self.middleItemNo = viewModel.chat?.lastReadMessageIndex ?? -1
            
            let messages = getMessages()
            if messages.count > middleItemNo && middleItemNo >= 0 {
                if messages[middleItemNo].type == .Video || messages[middleItemNo].type == .Audio {
                    viewModel.isPlaying = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.updatePreference = true
                }
            }
        }
        
        //TODO if no saved messages show an alert saying no saved message and telling them how to do it
    }
    
    func getMessages() -> [Message] {
        showSavedPosts ? viewModel.savedMessages : viewModel.messages
    }
}
