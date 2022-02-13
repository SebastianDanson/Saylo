//
//  NoMessagesView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-10.
//

import SwiftUI
import Kingfisher

struct NoMessagesView: View {
    
    let chat: Chat
    
    var body: some View {
        
        
        VStack {
            
            Spacer()
            
            
            ChatImageCircle(chat: chat, diameter: 110)
            
            Text(chat.name)
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 1)
                .padding(.bottom, 0.5)
            
            Text("Unsaved messages disappear after 24 hours")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(.systemGray))
            
            Text("Tap and hold on a message to save it")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(.systemGray))
            
            
            Spacer()
        }
    }
}

