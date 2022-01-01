//
//  AddFriendCell.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher

struct AddFriendCell: View {
    
    let user: User
    let addedMe: Bool
    let isSearch: Bool
    let viewModel = AddFriendsViewModel.shared
    
    @Binding var users: [User]
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            KFImage(URL(string: user.profileImageUrl))
                .resizable()
                .scaledToFill()
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .padding(.leading, 12)
            
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(user.firstName + " " + user.lastName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                
                Text(user.username)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                
                Button {
                    
                    addedMe ? viewModel.acceptFriendRequest(fromUser: user) : viewModel.sendFriendRequest(toUser: user)
                    self.users.removeAll(where: {$0.id == user.id})
                    
                } label: {
                    AddButton(addedMe: addedMe)
                        .padding(.trailing, addedMe ? 0 : 16)
                }

              
                
                if addedMe {
                    RemoveButton()
                }
            }
            
        }.frame(height: 60)
    }
}


struct AddButton: View {
    
    let addedMe: Bool
    
    var body: some View {
        
    
            Text(addedMe ? "Confirm" : "Add")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.mainBlue)
                .cornerRadius(4)
            
    }
}

struct RemoveButton: View {
    
    var body: some View {
        
        Button {
            
        } label: {
            
            HStack {
                
                Image("x")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(Color(.systemGray2))
                    .frame(width: 12, height: 12)
                    .padding()
            }
        }
    }
}

