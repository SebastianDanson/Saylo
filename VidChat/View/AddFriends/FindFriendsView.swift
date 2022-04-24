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
        
        VStack(spacing: 14) {
            
            VStack(spacing: 4) {
                
                Text("Welcome to Saylo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.systemBlack)
                    .padding(.top, 14)
                
                Text("Add friends and family to chat")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textGray)
                
            }
            
            Button {
                
                withAnimation {
                    ConversationGridViewModel.shared.showFindFriends = true
                    ConversationGridViewModel.shared.showAllFriends = false
                }
                
            } label: {
                
                Text("Find Friends")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.systemWhite)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 24)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                
            }.padding(.bottom, 12)
            
        }
        .frame(width: SCREEN_WIDTH - 40, height: 128)
        .background(Color.popUpSystemWhite)
        .cornerRadius(12)
        
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

