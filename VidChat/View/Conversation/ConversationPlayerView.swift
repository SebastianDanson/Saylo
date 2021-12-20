//
//  ConversationPlayerView.swift
//  VidChat
//
//  Created by Student on 2021-12-13.
//

import SwiftUI
import AVFoundation

struct ConversationPlayerView: View {
    
    @ObservedObject var viewModel = ConversationPlayerViewModel.shared
    @State var player: AVQueuePlayer
    @State var dateString = ""
    @State var dragOffset: CGSize = .zero
    
    private var token: NSKeyValueObservation?
    private var playerItems = [AVPlayerItem]()
    
    init() {
        
        var playerItems = [AVPlayerItem]()
        var dates = [Date]()
        ConversationViewModel.shared.messages.forEach({
            if $0.type == .Video, let urlString = $0.url, let url = URL(string: urlString) {
                let playerItem = AVPlayerItem(asset: AVAsset(url: url))
                playerItems.append(playerItem)
                dates.append($0.timestamp.dateValue())
            }
        })
        
        let player = AVQueuePlayer(items: playerItems)
        player.automaticallyWaitsToMinimizeStalling = false
        self.player = player
        self.player.play()
        self.playerItems = playerItems
        viewModel.dates = dates
    }
    
    
    var body: some View {
        
        ZStack {
            PlayerQueueView(player: $player)
                .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
            
            
            RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
        }
        .overlay(
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.linear(duration: 0.2)) {
                            ConversationViewModel.shared.showConversationPlayer = false
                        }
                    }, label: {
                        CamereraOptionView(image: Image("x"), imageDimension: 14, circleDimension: 32)
                            .padding(.horizontal, 8)
                            .padding(.top, 12)
                    })
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "house")
                        .clipped()
                        .scaledToFit()
                        .padding()
                        .background(Color.gray)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    Text("Sebastian")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    + Text(" • \(viewModel.dateString)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.white)
                    
                    Spacer()
                }
                .padding(24)
            })
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { gesture in
                    dragOffset.height = max(0, gesture.translation.height)
                }
                .onEnded { gesture in
                    withAnimation(.linear(duration: 0.2)) {
                        if dragOffset.height > SCREEN_HEIGHT / 4 {
                            ConversationViewModel.shared.showConversationPlayer = false
                        } else {
                            dragOffset.height = 0
                        }
                    }
                }
        )
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color(white: 0, opacity: 1))
        .offset(dragOffset)
    }
}
