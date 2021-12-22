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
    //    @State private var offsets: [Int: CGFloat] = [:]
    var mainViewHeight: CGFloat = (SCREEN_WIDTH * 16/9) / 2  // demo approximation
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var middleItemNo = -1
    @StateObject private var viewModel = ConversationViewModel.shared
    @Binding var dragOffset: CGSize
    @State private var canScroll = true
    @State private var hasScrolledToVideo = false
    let showSavedPosts: Bool
    @State var currentPlayer: AVPlayer?
    
    var body: some View {
        
        ScrollView {
            
            ScrollViewReader { reader in
                
                VStack(spacing: 0) {
                    
                    ForEach(Array(ConversationViewModel.shared.messages.enumerated()), id: \.1.id) { i, element in
                        MessageCell(message: getMessages()[i])
                            .transition(.move(edge: .bottom))
                            .offset(x: 0, y: -28)
                            .onAppear {
                                if i != getMessages().count - 1 {
                                    viewModel.players.first(where: {$0.messageId == getMessages()[i].id})?.player.pause()
                                }
                                
                                //TODO don't scroll if you're high up and ur not the one sending
                                //AKA ur watching an older vid and ur buddy send u don't wanna scroll
                                // if !isFirstLoad {
                                reader.scrollTo(getMessages().last!.id, anchor: .center)
                                //}
                            }
                            .background(
                                getMessages()[i].type == .Video ? GeometryReader { geo in
                                    Color.white.preference(
                                        key: ViewOffsetsKey.self,
                                        value: [i: geo.frame(in: .named("scrollView")).origin.y]) } : nil)
                    }
                }.flippedUpsideDown()
                
                    .onPreferenceChange( ViewOffsetsKey.self, perform: { prefs in
                        let prevMiddleItemNo = middleItemNo
                        middleItemNo = prefs.first(where: { $1 > -mainViewHeight && $1 < mainViewHeight })?.key ?? -1
                        
                        if middleItemNo >= 0 {
                            if prevMiddleItemNo != middleItemNo {
                                currentPlayer?.pause()
                                currentPlayer = viewModel.players.first(where: {$0.messageId == getMessages()[middleItemNo].id})?.player
                                playCurrentPlayer()
                                withAnimation {
                                    reader.scrollTo(getMessages()[middleItemNo].id, anchor: .center)
                                }
                            }
                        } else {
                            currentPlayer?.pause()
                        }
                    })
            }.padding(.top, !viewModel.showKeyboard && !viewModel.showPhotos ? 60 + BOTTOM_PADDING : -20)
                .padding(.bottom, 100)
            
        }
        .onDisappear(perform: {
            viewModel.players.forEach({$0.player.pause()})
            viewModel.players.removeAll()
        })
        .flippedUpsideDown()
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color.white)
        .coordinateSpace(name: "scrollView")
    }
    
    func playCurrentPlayer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPlayer?.play()
        }
    }
}
