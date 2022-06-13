//
//  ViewSavedMessagesButton.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct ViewSavedMessagesButton: View {
    
    var body: some View {
        
        ZStack {
            
            Color.init(white: 0.1)
            
            VStack(spacing: 8) {
                
                Image(systemName: "bookmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: MINI_MESSAGE_WIDTH/3.5, height: MINI_MESSAGE_HEIGHT/3.5)
                
                Text("Saved")
                    .foregroundColor(.white)
                    .font(Font.system(size: 16, weight: .medium))
            }
        }
        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
        .cornerRadius(6)
        .onTapGesture {
            ConversationViewModel.shared.getSavedPosts()
        }
    }
}

struct ViewSavedMessagesButtonSmall: View {
    
    var body: some View {
        
        Button {
            ConversationViewModel.shared.getSavedPosts()
        } label: {
            
            ZStack {
                
                Circle()
                    .foregroundColor(Color.init(white: 0.3))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "bookmark.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
            .padding(.trailing, 6)
            .padding(.top, 6)
        }
    }
}



