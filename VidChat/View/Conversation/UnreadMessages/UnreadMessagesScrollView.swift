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

//struct UnreadMessageView: View {
//
//    let chat: Chat
//
//    var body: some View {
//
//        ZStack(alignment: .topTrailing) {
//
//            VStack(alignment: .center, spacing: 4) {
//
//                ChatImageCircle(chat: chat, diameter: 60)
//                    .environment(\.colorScheme, .dark)
//
//                Text(chat.name)
//                    .font(.system(size: 12, weight: .regular))
//                    .foregroundColor(Color(.systemGray4))
//                    .frame(maxWidth: 64)
//            }
//
//        }
//    }
//}

