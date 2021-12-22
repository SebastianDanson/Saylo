//
//  ConversationFeedView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-21.
//

import SwiftUI
import AVFoundation

struct ConversationFeedView: View {
    
    @StateObject var viewModel = ConversationViewModel.shared
    @Binding var dragOffset: CGSize
    @State private var canScroll = true
    @State private var hasScrolledToVideo = false
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            ScrollViewReader { reader in
                VStack(spacing: 0) {
                    
                    ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, element in
                        
                        MessageCell(message: viewModel.messages[i])
                            .transition(.move(edge: .bottom))
                            .offset(x: 0, y: dragOffset.height - 28)
                            .onAppear {
                                if i != viewModel.messages.count - 1 {
                                    viewModel.players.first(where: {$0.messageId == viewModel.messages[i].id})?.player.pause()
                                }
                                
                                //TODO don't scroll if you're high up and ur not the one sending
                                //AKA ur watching an older vid and ur buddy send u don't wanna scroll
                                // if !isFirstLoad {
                                reader.scrollTo(viewModel.messages.last!.id, anchor: .center)
                                //}
                            }
                            .simultaneousGesture(
                                canScroll(atIndex: i) && canScroll  ?
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { gesture in
                                        dragOffset.height = gesture.translation.height
                                        hasScrolledToVideo = true
                                        viewModel.players.first(where: {$0.messageId == viewModel.messages[i].id})?.player.play()
                                    }
                                    .onEnded { gesture in
                                        handleOnDragEnd(translation: gesture.translation,
                                                        velocity: gesture.predictedEndLocation.y -
                                                        gesture.location.y,
                                                        index: i,
                                                        reader: reader)
                                    } : nil
                            )
                        
                        //}
                    }
                    
                }
                .flippedUpsideDown()
            } .padding(.top, !viewModel.showKeyboard && !viewModel.showPhotos ? 60 + BOTTOM_PADDING : -20)
                .padding(.bottom, 100)
        }
        .flippedUpsideDown()
    }
    
    func canScroll(atIndex i: Int) -> Bool {
        isScrollType(index: i) && isPrevScrollable(index: i) && isNextScrollable(index: i)
    }
    
    func isScrollType(index i: Int) -> Bool {
        viewModel.messages[i].type == .Video
    }
    
    func isPrevScrollable(index i: Int) -> Bool {
        (i > 0 && isScrollType(index: i - 1)) || i == 0
    }
    
    func isNextScrollable(index i: Int) -> Bool {
        (i < viewModel.messages.count - 1 && isScrollType(index: i + 1)) || (i == viewModel.messages.count - 1)
    }
    
    
    func handleOnDragEnd(translation: CGSize, velocity: CGFloat, index i: Int, reader: ScrollViewProxy) {
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            canScroll = true
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = .zero
        }
        
        if translation.height < 0 {
            if viewModel.messages.count > i + 1 {
                handleOnDragEndScroll(currentIndex: i, nextIndex: i+1)
            }
        }
        
        if translation.height > 0 {
            if i - 1 >= 0 {
                handleOnDragEndScroll(currentIndex: i, nextIndex: i-1)
            }
        }
        
        func handleOnDragEndScroll(currentIndex: Int, nextIndex: Int) {
            //  if hasScrolledToVideo {
            if abs(velocity) > 180 {
                if let currentMessagePlayer = viewModel.players.first(where: { $0.messageId == viewModel.messages[currentIndex].id }) {
                    currentMessagePlayer.player.pause()
                }
                //
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let nextMessagePlayer = viewModel.players.first(where: { $0.messageId == viewModel.messages[nextIndex].id }) {
                        nextMessagePlayer.player.seek(to: CMTime.zero)
                        nextMessagePlayer.player.play()
                    }
                }
                
                
                withAnimation() {
                    reader.scrollTo(viewModel.messages[nextIndex].id, anchor: .center)
                    canScroll = false
                }
                
            } else {
                withAnimation() {
                    reader.scrollTo(viewModel.messages[currentIndex].id, anchor: .center)
                    canScroll = false
                }
            }
        }
    }
}
