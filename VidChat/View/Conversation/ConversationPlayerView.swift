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
    @State var dateString = ""
    @State var dragOffset: CGSize = .zero

    private var token: NSKeyValueObservation?
    private var textMessages = [Message]()
    
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
        viewModel.player = player
        viewModel.player.play()
        viewModel.playerItems = playerItems
        viewModel.dates = dates
    }
    
    
    var body: some View {
        
        ZStack {
            
            if ConversationViewModel.shared.messages[viewModel.index].type == .Video {
                
                PlayerQueueView()
                    .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
                
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                    .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
                
            } else if ConversationViewModel.shared.messages[viewModel.index].type == .Text {
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 10))
                    .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
            } else if ConversationViewModel.shared.messages[viewModel.index].type == .Photo {
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.red, style: StrokeStyle(lineWidth: 10))
                    .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
            } else if ConversationViewModel.shared.messages[viewModel.index].type == .Audio {
                RoundedRectangle(cornerRadius: 24).strokeBorder(Color.green, style: StrokeStyle(lineWidth: 10))
                    .frame(width: SCREEN_WIDTH + 10, height: (SCREEN_WIDTH * 16/9) + 20)
            }
        }
        .overlay(
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.linear(duration: 0.2)) {
                            viewModel.removePlayerView()
                        }
                    }, label: {
                        CamereraOptionView(image: Image(systemName: "chevron.down"), imageDimension: 17, circleDimension: 32, topPadding: 3)
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
                .padding(.horizontal, 16)
                .padding(.vertical, 40)

            })
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color.black)
        .offset(dragOffset)
        .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
            dragOffset.height = max(0, gesture.translation.height)
        }
                    .onEnded({ (value) in
            
            if dragOffset.height == 0 {
                
                let xLoc = value.location.x
                
                if xLoc > SCREEN_WIDTH/2 {
                    viewModel.handleShowNextMessage()
                } else  {
                    viewModel.handleShowPrevMessage()
                }
            }
            
            withAnimation(.linear(duration: 0.2)) {
                
                if dragOffset.height > SCREEN_HEIGHT / 4 {
                    viewModel.removePlayerView()
                } else {
                    dragOffset.height = 0
                }
            }
            
        }))
   
    }
}
