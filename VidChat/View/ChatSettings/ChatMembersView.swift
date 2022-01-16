//
//  ChatMembersView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-16.
//

import SwiftUI

struct ChatMembersView: View {
    
    @Binding var showGroupMembers: Bool
    
    @State var chatMembers = ConversationViewModel.shared.chat?.chatMembers ?? [ChatMember]()
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        showGroupMembers = false
                    } label: {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(.systemBlue))
                            .padding(.leading, 16)
                    }
                    
                    Spacer()
                }
                
                Text("Members")
                    .fontWeight(.medium)
                
            }.frame(width: SCREEN_WIDTH, height: 44)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(chatMembers, id: \.id) { chatMember in
                        
                        ChatMemberCell(chatMember: chatMember)
                        
                        //Line divider
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(.dividerGray)
                                .frame(width: SCREEN_WIDTH - 76, height: 0.5)
                        }
                    }
                }.padding(.vertical, 12)
            }
            
            Spacer()
        }
    }
}


