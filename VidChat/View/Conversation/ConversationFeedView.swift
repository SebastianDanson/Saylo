//
//  ConversationFeedView.swift
//  Saylo
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
    @State var isFirstLoad = true
    @StateObject private var viewModel = ConversationViewModel.shared
    @Binding var messages: [Message]
    
    var body: some View {
        
        ScrollView {
            
            ScrollViewReader { reader in
                
                VStack(spacing: 0) {
                    
                    ForEach(Array(messages.enumerated()), id: \.1.id) { i, element in
                                                
                        MessageCell(message: messages[i])
                            .offset(x: 0, y: FEEDVIEW_OFFSET)
                            .background(
                                messages[i].type != .Text ? GeometryReader { geo in
                                    Color.systemWhite.preference(
                                        key: ViewOffsetsKey.self,
                                        value: [i: geo.frame(in: .named("scrollView")).midY]) } : nil)
                            .onAppear {
                                
                                if let chat = viewModel.chat {
                                    
                                    if isFirstLoad, i == chat.lastReadMessageIndex {
                                        reader.scrollTo(messages[i].id, anchor: .center)
                                    } else if isFirstLoad, chat.lastReadMessageIndex == -1, i == messages.count - 1 {
                                        reader.scrollTo(messages[i].id, anchor: .center)
                                    }
                                    
                                    if i == messages.count - 1 {
                                        
                                        if !isFirstLoad {
                                            
                                            self.temporarilyDisablePreference()
                                            
                                            if messages[i].type == .Video || messages[i].type == .Photo  {
                                                reader.scrollTo(messages[i].id, anchor: .center)
                                            } else {
                                                withAnimation {
                                                    reader.scrollTo(messages[i].id, anchor: .center)
                                                }
                                            }
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            isFirstLoad = false
                                        }
                                    }
                                }
                            }
                    }
                
                    if let seenByText = getSeenByText(), !viewModel.showSavedPosts  {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack {
                                
                                Text(seenByText)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.leading, 16)
                                
                                Spacer()
                            }
                        }
                    }

                }.flippedUpsideDown()
                
                    .onPreferenceChange(ViewOffsetsKey.self, perform: { prefs in
                       
                        guard updatePreference else { return }

                        DispatchQueue.main.async {

                            let prevMiddleItemNo = middleItemNo
                            middleItemNo = prefs.first(where: { abs(HALF_SCREEN_HEIGHT - $1 ) < 15 })?.key ?? -1


                            if middleItemNo >= 0 {

                                if prevMiddleItemNo != middleItemNo {


                                    self.temporarilyDisablePreference()

                                    withAnimation {
                                        reader.scrollTo(messages[middleItemNo].id, anchor: .center)
                                    }

                                    viewModel.updatePlayer(index: middleItemNo)

                                }
                            }
                            else {
                                viewModel.removeCurrentPlayer()
                            }
                        }
                    })
                    .onChange(of: viewModel.index, perform: { newValue in
                        
                        guard !viewModel.isShowingReactions else {return}
                        
                        middleItemNo += 1
                        if middleItemNo < 1 || middleItemNo >= messages.count {return}
                        
                        self.temporarilyDisablePreference()
                        
                        let message = messages[middleItemNo]
                        
                        if message.type == .Text || message.type == .Photo {
                            withAnimation {
                                reader.scrollTo(message.id, anchor: .center)
                            }
                        } else {
                            reader.scrollTo(message.id, anchor: .center)
                        }
                        
                        
                        viewModel.currentPlayer?.pause()
                        
                        viewModel.currentPlayer = viewModel.players.first(where: {$0.messageId == messages[middleItemNo].id})?.player
                        viewModel.currentPlayer?.play()
                        
                        
                    })
                    .onChange(of: viewModel.scrollToBottom) { newValue in
                        if let last = messages.last {
                            if viewModel.showKeyboard {
                                reader.scrollTo(last.id, anchor: .bottom)
                            } else {
                                reader.scrollTo(last.id, anchor: .center)
                            }
                        }
                    }
            }
            .padding(.top, !viewModel.showKeyboard && !viewModel.showPhotos ? 72 + BOTTOM_PADDING : -20)
            .padding(.bottom, 100)
            
        }
        .flippedUpsideDown()
        .coordinateSpace(name: "scrollView")
        .onAppear {
            
            self.middleItemNo = viewModel.chat?.lastReadMessageIndex ?? 0
            
            let messages = messages
            if messages.count > middleItemNo && middleItemNo >= 0 {
                
                if messages[middleItemNo].type == .Video || messages[middleItemNo].type == .Audio {
                    viewModel.isPlaying = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updatePreference = true
            }
        }
    }
    
    func temporarilyDisablePreference() {
        self.updatePreference = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updatePreference = true
        }
    }
    
    func getSeenByText() -> String? {
        
        guard let chat = viewModel.chat else {
            return nil
        }
        
        guard let uid = AuthViewModel.shared.currentUser?.id ?? UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)?.string(forKey: "userId") else {
            return nil
        }
        
        
        var seenText = "Seen by"
        
        viewModel.seenLastPost.forEach { userId in
            
            if let chatMember = chat.chatMembers.first(where: {$0.id == userId}), chatMember.id != uid {
                seenText += " \(chatMember.firstName)"
            }
        }
        
        return seenText == "Seen by" ? nil : seenText
    }
}
