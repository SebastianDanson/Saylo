//
//  TextCell.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Foundation
import Kingfisher

struct TextCell: View {
    
    let text: String
    let messageId: String
    let isSameIdAsPrevMessage: Bool
    let date: Date
    let profileImageUrl: String
    let name: String
    @State var isSaved: Bool
    @State var showAlert = false
    
    init(message: Message) {
        self.text = message.text ?? ""
        self.messageId = message.id
        self.isSameIdAsPrevMessage = message.isSameIdAsPrevMessage
        self.date = message.timestamp.dateValue()
        self.name = message.username
        self.profileImageUrl = message.userProfileImageUrl
        self._isSaved = State(initialValue: message.isSaved)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !isSameIdAsPrevMessage {
                
                KFImage(URL(string: profileImageUrl))
                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(name)
                                        .font(.system(size: 14, weight: .semibold))
                                    + Text(" • \(date.getFormattedDate())")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.mainGray)
                                    
                                    Text(text)
                                        .font(.system(size: 16))
                                }
                
            } else {
                Text(text)
                    .font(.system(size: 16))
                    .padding(.leading, 30 + 10)
                    
            }
            
            Spacer()
        }
        .background(Color.white)
        .padding(.horizontal, 12)
        .padding(.vertical, isSameIdAsPrevMessage ? 0 : 8)
        .onTapGesture {}
        .onLongPressGesture(perform: {
            withAnimation {
                if let i = getMessages().firstIndex(where: {$0.id == messageId}) {
                    if getMessages()[i].isSaved {
                        showAlert = true
                    } else {
                        ConversationViewModel.shared.updateIsSaved(atIndex: i)
                        isSaved.toggle()
                    }
                    
                }
            }
        })
        .frame(width: SCREEN_WIDTH)
        .overlay(
            ZStack {
                if isSaved {
                    
                    Button {
                        showAlert = true
                    } label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(white: 0, opacity: 0.3))
                            
                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 13, height: 13)
                        }
                        .padding(.horizontal, 12)
                    }
                    .alert(isPresented: $showAlert) {
                        savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == messageId}), completion: { isSaved in
                            self.isSaved = isSaved
                        })
                    }
                    
                }
            }
            ,alignment: .topTrailing)
    }
}

