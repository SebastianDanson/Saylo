//
//  WaitingForUserView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI
import Kingfisher

struct WaitingForUserView: View {
    
    let chat: Chat
    @Binding var hasJoinedCall: Bool
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                ZStack {
                    
                    Color.init(white: 0, opacity: 0.4)
                    
                    VStack {
                        
                        KFImage(URL(string: chat.profileImage))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding(.top, 4)
                        
                        VStack(spacing: 6) {
                            VStack(spacing: 0) {
                                
                                Text("Waiting for")
                                    .foregroundColor(.white)
                                    .font(Font.system(size: 12, weight: .medium, design: .rounded))
                                
                                Text(getWaitingForText())
                                    .foregroundColor(.white)
                                    .font(Font.system(size: 12, weight: .medium, design: .rounded))
                            }
                            
                            Button {
                                
                                withAnimation {
                                    hasJoinedCall = false
                                }
                                ConversationViewModel.shared.setIsOffCall()
                            } label: {
                                
                                HStack(spacing: 4) {
                                    
                                    Text("Leave")
                                        .foregroundColor(.white)
                                        .font(Font.system(size: 12, weight: .semibold, design: .rounded))
                                    
                                    Image("video")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 14, height: 14)
                                    
                                }
                                .frame(width: 64, height: 20)
                                .background(Color(.systemRed))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .frame(width: 80, height: 132)
                .cornerRadius(12)
                .padding(.top, TOP_PADDING + 70)
                .padding(.trailing, 12)
                
            }
            
            Spacer()
        }
    }
    
    func getWaitingForText() -> String {
        
        if chat.isDm {
            let uid = AuthViewModel.shared.getUserId()
            if let chatMember = chat.chatMembers.first(where: { $0.id != uid}) {
                return "\(chatMember.firstName)..."
            }
        }
        
        return "others..."
    }
}

