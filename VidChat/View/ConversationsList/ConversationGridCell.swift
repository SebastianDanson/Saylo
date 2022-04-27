//
//  ConversationGridCell.swift
//  Saylo
//
//  Created by Student on 2021-09-26.
//
import SwiftUI
import Kingfisher

struct ConversationGridCell: View {
    
    @Binding var chat: Chat
    
    let width = SCREEN_WIDTH/5.5
    let textColor: Color
    let diameter: CGFloat = IS_SE ? 52 : 58
    
    init(chat: Binding<Chat>, textColor: Color = .white) {
        self._chat = chat
        self.textColor = textColor
    }
    
    var body: some View {
        
        ZStack {
            
            Color.backgroundWhite.ignoresSafeArea()
            
            HStack(alignment:.top, spacing: 14) {
                
                ChatImageCircle(chat: chat, diameter: diameter)
                    .opacity(chat.chatMembers.count == 1 && !chat.isTeamSaylo ? 0.3 : 1)
                    .overlay(
                        ZStack {
                            
                            if chat.chatMembers.count == 1 && !chat.isTeamSaylo {
                                
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
                        })
                
                VStack(alignment: .leading, spacing: IS_SMALL_PHONE ? 3 : 4) {
                    
                    Spacer()
                    
                    Text(chat.isDm ? chat.fullName : chat.name)
                        .foregroundColor(.systemBlack)
                        .lineLimit(1)
                        .font(.system(size: IS_SMALL_PHONE ? 17 : 18, weight: .medium))
                    
                    Text(getChatText())
                        .foregroundColor(Color(.systemGray))
                        .font(.system(size: IS_SMALL_PHONE ? 14 : 15, weight: .regular))
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                
                
                VStack {
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        
                        if chat.hasUnreadMessage {
                            
                            Circle()
                                .frame(width: 13, height: 13)
                                .foregroundColor(.mainBackgroundBlue)
                        }
                        
                        Button {
                            
                            withAnimation {
                                ConversationGridViewModel.shared.selectedSettingsChat = chat
                            }
                            
                        } label: {
                            
                            Image("ChatOptions")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(red: 192/255, green: 193/255, blue: 199/255, opacity: 1))
                                .frame(width: 5, height: 20)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, IS_SE ? 0 : (IS_SMALL_PHONE ? 2 : 6))
        .frame(width: SCREEN_WIDTH)
    }
    
    func getChatText() -> String {
        
        if chat.messages.count == 0 {
            return "Tap to send a Saylo"
        }
        
        let lastMessage = chat.messages.last!
        let timeAgo = Date().timeIntervalSince1970 - lastMessage.timestamp.dateValue().timeIntervalSince1970
        let fromText = lastMessage.isFromCurrentUser ? "Sent " : "Received "
        
        if chat.isTeamSaylo {
            return "Learn about Saylo"
        }
        
        if timeAgo < 60 {
            return fromText + "just now"
        }
        
        if timeAgo < 3600 {
            return fromText + String(Int(floor(timeAgo/60))) + " min ago"
        }
        
        let numHours = Int(floor(timeAgo/3600))
        
        return fromText + String(numHours) + " \(numHours == 1 ? "hour" : "hours") ago"
        
    }
}


