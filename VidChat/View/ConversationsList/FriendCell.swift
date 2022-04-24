//
//  FriendCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-24.
//


import SwiftUI
import Kingfisher

struct FriendCell: View {
    
    let chatMember: ChatMember?
    
    init(chat: Chat) {
        let uid = AuthViewModel.shared.getUserId()
        if let chatMember = chat.chatMembers.first(where: {$0.id != uid }) {
            self.chatMember = chatMember
        } else {
            self.chatMember = nil
        }
    }
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            if let chatMember = chatMember {
                
                
                KFImage(URL(string: chatMember.profileImage))
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.systemWhite)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .padding(.leading, 12)
                
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(chatMember.firstName + " " + chatMember.lastName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.systemBlack)
                    
                    Text(chatMember.username)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                    
                }
                
                Spacer()
                                
            }
        }
        .frame(height: 60)

    }
}



