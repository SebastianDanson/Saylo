//
//  UnreadMessagesScrollView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-20.
//

import SwiftUI

struct UnreadMessagesScrollView: View {
    
    @ObservedObject var viewModel = ConversationPlayerViewModel.shared
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, message in
                        
                        Button {
                            viewModel.index = i
                        } label: {
                            
                            ZStack {
                                
                                if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == message.chatId}) {
                                    
                                    ZStack {
                                        
                                        if i == viewModel.index {
                                            
                                            Circle().stroke(Color.mainBlue, lineWidth: 2)
                                                .frame(width: 64, height: 64)
                                                .transition(.opacity)
                                            
                                        }
                                        
                                        ChatImageCircle(chat: chat, diameter: 56)
                                            .overlay(ReplyView(isForTakingVideo: message.isForTakingVideo))
                                            .environment(\.colorScheme, .dark)
                                            .padding(.horizontal, 4)
                                        
                                        
                                    }
                                }
                                
                            }.frame(width: 68, height: 68)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 68)
            }
        }
    }
}

struct ReplyView: View {
    
    
    let isForTakingVideo: Bool
    
    var body: some View {
        
        ZStack {
            
            if isForTakingVideo == true {
                
                ZStack {
                    
                    
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                    
                }
                .frame(width: 56, height: 56)
                .background(Color.init(white: 0, opacity: 0.4))
                .clipShape(Circle())
            }
        }
    }
}


