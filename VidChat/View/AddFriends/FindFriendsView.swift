//
//  FindFiendsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher

struct FindFriendsView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.backgroundWhite
            
            VStack(spacing: 8) {
                
                
                ZStack {
                    
                    Color.alternateMainBlue
                    
                    VStack {
                        
                        Spacer()
                        
                        Text("Welcome to Saylo")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                    }
                    
                }
                .frame(width: SCREEN_WIDTH - 40, height: 60)
                
                
                VStack {
                    
                    Spacer()
                    
                    if ConversationGridViewModel.shared.isCalling {
                        Text("Add friends and family make a call")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.textGray)
                    } else {
                        Text("Add friends and family to create a chat")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.textGray)
                    }
                    
                    
                    Button {
                        
                        withAnimation {
                            ConversationGridViewModel.shared.showNewChat = false
                            ConversationGridViewModel.shared.isCalling = false
                            ConversationGridViewModel.shared.showFindFriends = true
                            ConversationGridViewModel.shared.showAllFriends = false
                        }
                        
                    } label: {
                        
                        Text("Find Friends")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.systemWhite)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(Color.alternateMainBlue)
                            .clipShape(Capsule())
                            .padding(.top, 8)
                        
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
            }
        }
        .frame(width: SCREEN_WIDTH - 40, height: 180)
        .cornerRadius(12)
        .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
        
    }
}

struct TipView: View {
    
    let header: String
    let subText: String
    let imageName: String
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            VStack(spacing: 4) {
                
                Text(header)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.systemBlack)
                    .padding(.top, 15)
                
                Text(subText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textGray)
                
            }
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.mainBlue)
                .frame(width: 40, height: 40)
                .padding(.bottom, 15)
            
        }
        .frame(width: SCREEN_WIDTH - 40, height: 150)
        .background(Color.popUpSystemWhite)
        .cornerRadius(12)
        .padding(.vertical, 28)
        
    }
}

