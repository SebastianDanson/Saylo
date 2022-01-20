//
//  SuggestedChatsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI

struct SuggestedChatsView: View {
    
    var chats: [Chat]
    
    var body: some View {
        
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                            
                            Button {
                                ConversationViewModel.shared.sendCameraMessage(chatId: chat.id, chat: chat)
                                CameraViewModel.shared.reset(hideCamera: true)
                            } label: {
                                SuggestedChatView(chat: chat)
                                    .padding(.horizontal, 6)
                                    .scaleEffect(x: -1, y: 1, anchor: .center)
                            }

                        }
                        
                    }
                }
                .padding(.horizontal, 12)
                .scaleEffect(x: -1, y: 1, anchor: .center)
            }
        }
        .frame(width: SCREEN_WIDTH, height:  100)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color(white: 0, opacity: 0.8))
        .cornerRadius(16)
        .transition(.identity)
    }
}

struct SuggestedChatView: View {
    
    let chat: Chat
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center, spacing: 4) {
                
                ChatImage(chat: chat, width: 60)
                    .environment(\.colorScheme, .dark)

                Text(chat.name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(.systemGray4))
                    .frame(maxWidth: 68)
            }
            
        }
    }
}