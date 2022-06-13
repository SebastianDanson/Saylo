//
//  LiveUsersView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI
import Kingfisher

struct LiveUsersView: View {
    
    @Binding var liveUsers: [String]
    var reader: ScrollViewProxy
    
    var body: some View  {
        
        ForEach(Array(liveUsers.enumerated()), id: \.1) { i, id in
            
            if id != AuthViewModel.shared.getUserId(), let chatMember = getChatMember(fromId: id) {
                
                ZStack {
                    
                    Color.init(white: 0.1)
                    
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        KFImage(URL(string: chatMember.profileImage))
                            .resizable()
                            .scaledToFill()
                            .frame(width: MINI_MESSAGE_WIDTH/1.3, height: MINI_MESSAGE_HEIGHT/1.3)
                            .clipShape(Circle())
                        
                        HStack(spacing: 5) {
                            
                            Spacer()
                            
                            Circle()
                                .frame(width: 11, height: 11)
                                .foregroundColor(Color(.systemRed))
                            
                            Text("Live")
                                .foregroundColor(.white)
                                .font(Font.system(size: 14, weight: .semibold))
                            
                            Spacer()
                            
                        }
                        
                        Spacer()
                    }
                }
                .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                .cornerRadius(6)
                .onTapGesture {
                    ConversationViewModel.shared.currentlyWatchingId = id
                    ConversationViewModel.shared.isLive = true
                }
                .onAppear {
                    reader.scrollTo(id, anchor: .trailing)
                }
            }
        }
    }
    
    func getChatMember(fromId id: String) -> ChatMember? {
        
        guard let chat = ConversationViewModel.shared.chat else { return nil }
        return chat.chatMembers.first(where: {$0.id == id})
    }
}
