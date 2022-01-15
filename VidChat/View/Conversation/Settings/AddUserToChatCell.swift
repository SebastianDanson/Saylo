//
//  AddUserToChatCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI

struct AddUserToChatCell: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    let chat: Chat
    
    var body: some View {
        
        Button {
            viewModel.handleChatSelected(chat: chat)
        } label: {
            
            HStack(spacing: 12) {
                
                ChatImage(chat: chat, diameter: 40)
                    .padding(.leading, 12)
                
                
                Text(chat.fullName)
                    .lineLimit(2)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.systemBlack)
                
                Spacer()
                
                Circle()
                    .stroke(viewModel.containsChat(chat) ? Color.systemWhite : Color.lighterGray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    .frame(width: 28, height: 28)
                    .overlay(
                        ZStack {
                            if viewModel.containsChat(chat) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.mainBlue)
                            }
                        }
                    )
                    .padding(.horizontal)
                
            }.frame(height: 52)
        }

    }
}


