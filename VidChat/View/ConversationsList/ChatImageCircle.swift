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
    let width: CGFloat
    let addedWidth: CGFloat
    
    init(chat: Chat, width: CGFloat) {
        
        let currentUserId = AuthViewModel.shared.getUserId()
        
        if chat.isDm || chat.profileImage != "" {
            self.profileImage1 = chat.profileImage
            self.profileImage2 = nil
        } else {
            var chatMembers = chat.chatMembers
            
            chatMembers.removeAll(where: {$0.id == currentUserId})
            
            self.profileImage1 = chatMembers[0].profileImage
            
            if chatMembers.count > 1{
                self.profileImage2 = chatMembers[1].profileImage
            } else {
                self.profileImage2 = nil
            }
        }
        
        self.width = width
        self.addedWidth = width/25 + 1
        
    }
    
    var body: some View {
        
        if let profileImage2 = profileImage2 {
            
            ZStack {
                
                ZStack {
                    

                    Circle()
                        .stroke(Color.lighterGray, lineWidth: addedWidth)
                        .frame(width: width/1.8 + addedWidth, height:  (width/1.8 + addedWidth))

                    KFImage(URL(string: profileImage1))
                        .resizable()
                        .scaledToFill()
                        .frame(width: width/1.8 + addedWidth, height:  (width/1.8 + addedWidth))
                        .cornerRadius(9)
                    
                }
                .padding(.top, width/2.3)
                .padding(.trailing, width/3.2)
                .zIndex(2)
                      
                KFImage(URL(string: profileImage2))
                    .resizable()
                    .scaledToFill()
                    .frame(width: width/1.8 + addedWidth, height: (width/1.8 + addedWidth))
                    .cornerRadius(10)
                    .padding(.bottom, width/2.3)
                    .padding(.leading, width/3.1)
                
            }
            .frame(width: width, height: width)
            .background(Color.lighterGray)
            .cornerRadius(width/2)
            .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 10, x: 0, y: 2)

            
        } else {
            
            KFImage(URL(string: profileImage1))
                .resizable()
                .scaledToFill()
                .background(Color(.systemGray))
                .frame(width: width, height: width)
                .cornerRadius(width/2)
                .shadow(color: Color(.init(white: 0, alpha: 0.12)), radius: 10, x: 0, y: 6)
//                .clipShape(Circle())
        }
        
    }
}




struct ChatImageCircle: View {
    
    let profileImage1: String
    let profileImage2: String?
    let diameter: CGFloat
    let addedWidth: CGFloat
    
    init(chat: Chat, diameter: CGFloat) {
        
        let currentUserId = AuthViewModel.shared.currentUser?.id ?? ""
        
        if chat.isDm || chat.profileImage != "" {
            self.profileImage1 = chat.profileImage
            self.profileImage2 = nil
        } else {
            var chatMembers = chat.chatMembers
            
            chatMembers.removeAll(where: {$0.id == currentUserId})
            
            self.profileImage1 = chatMembers[0].profileImage
            
            if chatMembers.count > 1 {
                self.profileImage2 = chatMembers[1].profileImage
            } else {
                self.profileImage2 = nil
            }
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


