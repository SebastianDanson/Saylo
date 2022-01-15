//
//  AddedChatsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI

struct AddedChatsView: View {
    
    @Binding var chats: [Chat]
    
    var body: some View {
        
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                            AddedUserView(chats: $chats, chat: chat)
                                .padding(.leading, i == 0 ? 20 : 5)
                                .padding(.trailing, i == chats.count - 1 ? 80 : 5)
                                .transition(.scale)
                            
                        }
                        
                    }.padding(.vertical)
                }.frame(width: SCREEN_WIDTH - 40, height:  60)
            }
        }
        .transition(.identity)
    }
}

struct AddedUserView: View {
    
    @Binding var chats: [Chat]

    let chat: Chat
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center, spacing: 4) {
                
                ChatImage(chat: chat, diameter: 44)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(chat.name)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 136/255, green: 137/255, blue: 141/255))
                    .frame(maxWidth: 50)
            }
            
            Button {
                withAnimation {
                    chats.removeAll(where: { $0.id == chat.id})
                }
            } label: {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.toolBarIconGray)
                        .frame(width: 20, height: 20)
                    
                    Image("x")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(white: 0.4, opacity: 1))
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    
                }
                .padding(.top, 4)
                .padding(.trailing, -6)
            }
        }
    }
}

