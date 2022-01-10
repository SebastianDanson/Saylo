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
    
    var message: Message
    
    @State var showAlert = false
    
//    init(message: Binding<Message>) {
//        self._message = message
//    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .bottom, spacing: 10) {
                
                KFImage(URL(string: message.userProfileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .opacity(message.isSameIdAsNextMessage ? 0 : 1)
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if !message.isSameIdAsPrevMessage {
                        Text(message.username)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(message.isFromCurrentUser ? .white : .systemBlack)

                        + Text(" • \(message.timestamp.dateValue().getFormattedDate())")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(message.isFromCurrentUser ? .white : .mainGray)
                        }
                        Text(message.text ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(message.isFromCurrentUser ? .white : .systemBlack)

                    }
                    .padding(.vertical, 8)
                    .padding(.leading, 12)

                    Spacer()
                }
                .frame(width: SCREEN_WIDTH - 60)
                .background(message.isFromCurrentUser ? .mainBlue : Color.textBackground)
                .cornerRadius(16)
                
                Spacer()
            }.padding(.leading)
            
            
        }
        .padding(.horizontal, 12)
        .padding(.top, message.isSameIdAsPrevMessage ? 2 : 6)
        .padding(.bottom, message.isSameIdAsNextMessage ? 2 : 6)
        .onTapGesture {}
        .onLongPressGesture(perform: {
            withAnimation {
                if let i = getMessages().firstIndex(where: {$0.id == message.id}) {
                    if getMessages()[i].isSaved {
                        showAlert = true
                    } else {
                        ConversationViewModel.shared.updateIsSaved(atIndex: i)
                        message.isSaved.toggle()
                    }
                    
                }
            }
        })
        .frame(width: SCREEN_WIDTH)
        .overlay(
            ZStack {
                if message.isSaved {
                    
                    Button {
                        showAlert = true
                    } label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.point3AlphaSystemBlack)
                            
                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.systemWhite)
                                .frame(width: 13, height: 13)
                        }
                        .padding(.horizontal, 12)
                    }
                    .alert(isPresented: $showAlert) {
                        savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
                            message.isSaved = isSaved
                        })
                    }
                    
                }
            }
            ,alignment: .topTrailing)
    }
}

