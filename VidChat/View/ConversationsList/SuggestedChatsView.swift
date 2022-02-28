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
        
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack {
                
                ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                    
                    Button {
                        ConversationViewModel.shared.sendCameraMessage(chatId: chat.id, chat: chat)
//                        MainViewModel.shared.reset(hideCamera: true)
                    } label: {
                        ChatImageCircle(chat: chat, diameter: 64)
                            .environment(\.colorScheme, .dark)
                            .padding(.horizontal, 3)
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                    }
                }
            }
        }
        .scaleEffect(x: -1, y: 1, anchor: .center)
        
    }
}

struct SuggestedChatView: View {
    
    let chat: Chat
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center, spacing: 4) {
                
                ChatImageCircle(chat: chat, diameter: 60)
                    .environment(\.colorScheme, .dark)

                Text(chat.name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(.systemGray4))
                    .frame(maxWidth: 68)
            }
            
        }
    }
}
