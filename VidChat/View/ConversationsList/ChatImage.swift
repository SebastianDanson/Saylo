//
//  ChatImage.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-07.
//

import SwiftUI
import Kingfisher

struct ChatImage: View {
    
    let profileImage1: String
    let profileImage2: String?
    let diameter: CGFloat
    let addedWidth: CGFloat
    
    init(chat: Chat, diameter: CGFloat) {
        
        let currentUserId = AuthViewModel.shared.currentUser?.id ?? ""
        
        if chat.isDm || chat.profileImageUrl != "" {
            self.profileImage1 = chat.profileImageUrl
            self.profileImage2 = nil
        } else {
            var chatMembers = chat.chatMembers
            
            chatMembers.removeAll(where: {$0.id == currentUserId})
            
            self.profileImage1 = chatMembers[0].profileImage
            self.profileImage2 = chatMembers[1].profileImage
        }
        
        self.diameter = diameter
        self.addedWidth = diameter/25
    }
    
    var body: some View {
        
        if let profileImage2 = profileImage2 {
            
            ZStack {
                
                ZStack {
                    
                    Circle().stroke(Color.lighterGray, lineWidth: addedWidth)
                        .frame(width: diameter/2 + addedWidth * 2, height: diameter/2 + addedWidth * 2)
                    
                    KFImage(URL(string: profileImage1))
                        .resizable()
                        .scaledToFill()
                        .frame(width: diameter/2 + addedWidth, height: diameter/2 + addedWidth)
                        .clipShape(Circle())
                    
                }
                .padding(.top, diameter/3 - addedWidth)
                .padding(.trailing, diameter/3 - addedWidth)
                .zIndex(2)
                
                
                
                KFImage(URL(string: profileImage2))
                    .resizable()
                    .scaledToFill()
                    .frame(width: diameter/2 + addedWidth, height: diameter/2 + addedWidth)
                    .clipShape(Circle())
                    .padding(.bottom, diameter/3 - addedWidth)
                    .padding(.leading, diameter/3 - addedWidth)
                
            }
            .frame(width: diameter, height: diameter)
            .background(Color.lighterGray)
            .clipShape(Circle())
            
        } else {
            KFImage(URL(string: profileImage1))
                .resizable()
                .scaledToFill()
                .background(Color(.systemGray))
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
        }
        
    }
}


