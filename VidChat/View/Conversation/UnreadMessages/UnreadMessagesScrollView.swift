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
        
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, message in
                            
                            Button {
                                //                                ConversationViewModel.shared.sendCameraMessage(chatId: chat.id, chat: chat)
                                //                                CameraViewModel.shared.reset(hideCamera: true)
                            } label: {
                                ZStack {
                                    if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == message.chatId}) {
                                        ChatImageCircle(chat: chat, diameter: 60)
                                            .environment(\.colorScheme, .dark)
                                            .padding(.horizontal, 3)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(width: SCREEN_WIDTH)
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

