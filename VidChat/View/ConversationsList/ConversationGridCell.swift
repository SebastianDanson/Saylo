//
//  ChatCell.swift
//  Saylo
//
//  Created by Student on 2021-09-26.
//

import SwiftUI
import Kingfisher

struct ConversationGridCell: View {
    
    @Binding var chat: Chat
    let width = SCREEN_WIDTH/4.2
    let textColor: Color
    
    init(chat: Binding<Chat>, textColor: Color = Color(red: 96/255, green: 97/255, blue: 100/255)) {
        self._chat = chat
        self.textColor = textColor
    }
    
    var body: some View {
        
        ZStack(alignment:.top) {
            
            VStack(alignment: .center, spacing: 6) {
                
                ZStack {
                    
                    ChatImage(chat: chat, width: width)
                        .opacity(chat.chatMembers.count == 1 ? 0.3 : 1)
                        .overlay(
                            
                            ZStack {
                                
                                if chat.chatMembers.count == 1 {
                                    VStack {
                                        
                                        HStack {
                                            Image(systemName: "hourglass")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .padding(.leading, 4)
                                                .padding(.top, 8)
                                                .foregroundColor(.systemBlack)
                                            
                                            Spacer()
                                            
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                }
                                
                                if chat.hasSent {
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .frame(width: width, height: width)
                                            .foregroundColor(.mainBlue)
                                            .opacity(0.9)
                                        
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: width/3, height: width/3)
                                            .foregroundColor(.systemWhite)
                                    }.transition(.opacity)
                                    
                                }
                                
                                
                                
                                if chat.isSending {
                                    VStack {
                                        Spacer()
                                        ActivityIndicatorRectangle(shouldAnimate: $chat.isSending, width: width - 28)
                                            .padding(.bottom, 10)
                                            .transition(.opacity)
                                        
                                    }
                                }
                            }
                        )
                }
                
                
                Text(chat.name)
                    .font(.system(size: 13, weight: .regular))
                    .lineLimit(1)
                    .foregroundColor(textColor)
                    .overlay(
                        ZStack {
                            if chat.hasUnreadMessage {
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.mainBlue)
                            }
                        }.padding(.leading, -17)
                        
                        , alignment: .leading
                    )
                
            }.overlay(
                ZStack {
                    
                    if chat.isSelected {
                        
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .background(Circle().frame(width: 30, height: 30).foregroundColor(.systemWhite))
                            .scaledToFit()
                            .foregroundColor(.mainBlue)
                            .transition(.scale)
                    }
                }
                , alignment: .topLeading
                
            )
        }
    }
}

//struct NameView: View {
//    let firstName: String
//    let lastName: String
//    let width = (UIScreen.main.bounds.width-66) / 3
//
//    var body: some View {
//        Text(firstName)
//            .font(.system(size: 15, weight: .medium))
//            .padding(.vertical, 8)
//            .padding(.horizontal, 12)
//            .background(Color(.init(white: 1, alpha: 1)))
//            .clipShape(Capsule())
//    }
//}

struct ConversationStatusView: View {
    let image: String
    let isOpened: Bool
    let isSent: Bool
    
    init(image: String, conversationStatus: ConversationStatus) {
        self.image = image
        
        switch conversationStatus {
        case .sent:
            isOpened = false
            isSent = true
        case .received:
            isOpened = false
            isSent = false
        case .receivedOpened:
            isOpened = true
            isSent = false
        case .sentOpened:
            isOpened = true
            isSent = true
        case .none:
            isOpened = false
            isSent = false
        }
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 16, height: 16)
            .scaledToFit()
            .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 6, x: 0, y: 4)
    }
}

