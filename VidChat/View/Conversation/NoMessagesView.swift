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
                .foregroundColor(.white)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .padding(.top, 1)
                .padding(.bottom, 0.5)
                       
            Text("Unsaved Saylos disappear after 48h")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.bottom, 40)
            
            Spacer()            
          
        }
        .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT)
//        .background(Color.blue)
//        .cornerRadius(14)
//        .padding(.top, TOP_PADDING_OFFSET)
    }
}

