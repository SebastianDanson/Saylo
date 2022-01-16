//
//  ChatMemberCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-16.
//

import SwiftUI
import Kingfisher

struct ChatMemberCell: View {
    
    let chatMember: ChatMember
    let viewModel = ChatSettingsViewModel.shared
        
    @State var wasSelected = false
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            KFImage(URL(string: chatMember.profileImage))
                .resizable()
                .scaledToFill()
                .foregroundColor(.systemWhite)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .padding(.leading, 20)
            
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(chatMember.firstName + " " + chatMember.lastName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.systemBlack)
                
                Text(chatMember.username)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
     
                AddChatMemberButton(chatMember: chatMember)
                    .padding(.trailing, 20)
                
          
        }
        .frame(height: 60)
        
     }
}


struct AddChatMemberButton: View {
    
    @State var wasAdded = false
    @State var didAcceptRequest = false
    @State var hasRequestFromMember: Bool

    let viewModel = AddFriendsViewModel.shared
    
    let chatMember: ChatMember
    
    init(chatMember: ChatMember) {
        
        self.chatMember = chatMember
        
        var hasRequestFromMember = false
        
        if let currentUser = AuthViewModel.shared.currentUser {
            if currentUser.friendRequests.contains(chatMember.id) {
                hasRequestFromMember = true
            }
        }
        
        self._hasRequestFromMember = State(initialValue: hasRequestFromMember)
    }
    
    var body: some View {
        
        Button {
            
            if hasRequestFromMember {
                viewModel.acceptFriendRequest(fromUser: chatMember)
                didAcceptRequest = true
            } else if !wasAdded {
                viewModel.sendFriendRequest(toUser: chatMember)
                wasAdded = true
            } else {
                viewModel.sendFriendRequest(toUser: chatMember)
                wasAdded = false
            }
            
        } label: {
            ZStack {
                
                if let currentUser = AuthViewModel.shared.currentUser  {
                    
                    if !currentUser.friends.contains(chatMember.id) && currentUser.id != chatMember.id {
                        Text(setText())
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(wasAdded && !hasRequestFromMember || didAcceptRequest ? Color.lightGray : Color.mainBlue)
                            .cornerRadius(4)
                    }
                }
            }
        }.disabled(didAcceptRequest)
  
    }
    
    func setText() -> String {
        
        if hasRequestFromMember {
            return didAcceptRequest ? "Added" : "Confirm"
        }
        
        return wasAdded ? "Requested" : "Add"
    }
}
