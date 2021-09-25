//
//  ProfileActionButton.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct ProfileActionButton: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @State var showEditProfile = false
    
    var isFollowed: Bool { return viewModel.user.isFollowed ?? false }
    
    var body: some View {
        if viewModel.user.isCurrentUser {
            Button(action: {showEditProfile.toggle()}, label: {
                Text("Edit Profile")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 360, height: 32)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.gray, lineWidth: isFollowed ? 1 : 0)
                        
                    )
            })
            .cornerRadius(3)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        } else {
            HStack {
                Button(action: { isFollowed ? viewModel.unfollow() : viewModel.follow() }, label: {
                    Text(isFollowed ? "Following" : "Follow")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 172, height: 32)
                        .foregroundColor(isFollowed ? .black : .white)
                        .background(isFollowed ? Color.white : Color.blue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.gray, lineWidth: 1.0)
                            
                        )
                })
                
                Button(action: {}, label: {
                    Text("Message")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 172, height: 32)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.gray, lineWidth: 1.0)
                            
                        )
                })
            }
        }
    }
}
