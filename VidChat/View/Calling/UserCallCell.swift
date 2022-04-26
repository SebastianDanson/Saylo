//
//  UserCallCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-25.
//

import SwiftUI

struct UserCallCell: View {
    
    @Binding var chat: Chat
    
    let width = SCREEN_WIDTH/5.5
    let diameter: CGFloat = 46
    
    init(chat: Binding<Chat>) {
        self._chat = chat
    }
    
    var body: some View {
        
        ZStack {
            
            Color.systemWhite.ignoresSafeArea()
            
            VStack {
                HStack(alignment:.top, spacing: 14) {
                    
                    ChatImageCircle(chat: chat, diameter: diameter)
                    
                    
                    VStack(alignment: .leading) {
                        
                        Spacer()
                        
                        Text(chat.fullName)
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                    }
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(width: SCREEN_WIDTH - 40, height: 1)
                    .foregroundColor(Color(red: 232/255, green: 232/255, blue: 232/255))
                    .padding(.top, 10)
                
            }
        }
        .padding(.horizontal, 20)
        .frame(width: SCREEN_WIDTH)
    }
}
