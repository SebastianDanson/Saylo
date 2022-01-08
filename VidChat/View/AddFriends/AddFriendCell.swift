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
    let viewModel = AddFriendsViewModel.shared
    
    @Binding var users: [User]
    
    @State var wasSelected = false
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            KFImage(URL(string: user.profileImageUrl))
                .resizable()
                .scaledToFill()
                .foregroundColor(.systemWhite)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .padding(.leading, 12)
            
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(user.firstName + " " + user.lastName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.systemBlack)
                
                Text(user.username)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                
                Button {
                    
                    var wasSelected: Bool
                    
                    if addedMe {
                        viewModel.acceptFriendRequest(fromUser: user)
                        wasSelected = true
                    } else {
                        
                        if self.wasSelected {
                            viewModel.removeFriendRequest(toUser: user)
                            wasSelected = false
                        } else {
                            viewModel.sendFriendRequest(toUser: user)
                            wasSelected = true
                        }
                    }
                    
                    withAnimation {
                        self.wasSelected = wasSelected
                    }
                    
                } label: {
                    AddButton(wasSelected: $wasSelected, addedMe: addedMe, user: user)
                        .padding(.trailing, addedMe && !wasSelected ? 0 : 16)
                }.disabled(wasSelected && addedMe)
                
                
                
                if addedMe && !wasSelected {
                    
                    Button {
                        self.users.removeAll(where: {$0.id == user.id})
                        viewModel.rejectFriendRequest(fromUser: user)
                    } label: {
                        RemoveButton()
                    }
                }
            }
            
        }
        .frame(height: 60)
        .onAppear {
            if user.friendRequests.contains(AuthViewModel.shared.currentUser?.id ?? "") {
                wasSelected = true
            }
        }
    }
}


struct AddButton: View {
    
    @Binding var wasSelected: Bool
    
    let addedMe: Bool
    let user: User
    
    
    var body: some View {
        
        ZStack {
            
            if !user.friends.contains(AuthViewModel.shared.currentUser?.id ?? "") {
                Text(setText())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(wasSelected ? Color.lightGray : Color.mainBlue)
                    .cornerRadius(4)
            }
            
        }
        
    }
    
    func setText() -> String {
        
        if addedMe {
            return wasSelected ? "Added" : "Confirm"
        } else {
            return wasSelected ? "Requested" : "Add"
        }
    }
}

struct RemoveButton: View {
    
    var body: some View {
        
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

