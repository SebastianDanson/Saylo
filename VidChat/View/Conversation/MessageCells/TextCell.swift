//
//  TextCell.swift
//  Saylo
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Foundation
import Kingfisher

struct TextCell: View {
    
    var message: Message
    
    @State var showAlert = false
    @State var isSaved: Bool
    @StateObject var viewModel = ConversationViewModel.shared
    
    init(message: Message) {
        self.message = message
        self._isSaved = State(initialValue: message.isSaved)
    }
    
    var body: some View {
        
        let gesture = LongPressGesture()
            .onEnded { _ in
                withAnimation {
                    
                    if let i = getMessages().firstIndex(where: {$0.id == message.id}) {
                        
                        if getMessages()[i].isSaved {
                            if getMessages()[i].savedByCurrentUser{
                                showAlert = true
                            }
                        } else {
                            ConversationViewModel.shared.updateIsSaved(atIndex: i)
                            isSaved.toggle()
                        }
                        
                    }
                }
            }
        
        ZStack {
            
            HStack(alignment: .bottom, spacing: 10) {
                
                KFImage(URL(string: message.userProfileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .opacity(message.isSameIdAsNextMessage ? 0 : 1)
                
                HStack(alignment: .center, spacing: 10) {
                    
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
                    .background(message.isFromCurrentUser ? .mainBlue : Color.textBackground)
                    .cornerRadius(16)
                    
                    
                    if isSaved {
                        
                        Button {
                            showAlert = true
                        } label: {
                            ZStack {
                                
                                Circle()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(message.savedByCurrentUser ? .mainBlue : .lightGray)
                                
                                Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash.fill" : "bookmark.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.systemWhite)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
                                withAnimation {
                                    self.isSaved = isSaved
                                    message.isSaved = isSaved
                                }
                            })
                        }
                        
                    }
                }
                
                Spacer()
                
            }
            //            .padding(.leading)
            
            
        }
        .overlay(
            
            ZStack {
                
                if viewModel.sendingMessageId == message.id {
                    
                    if viewModel.isSending {
                        ActivityIndicator(shouldAnimate: .constant(true), diameter: 20)
                    } else if viewModel.hasSent {
                        ZStack {

                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .opacity(0.9)

                            Image(systemName: "checkmark")
                                .resizable()
                                .font(Font.title.weight(.semibold))
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.mainBlue)

                        }.transition(.opacity)

                    }
                }
            }
                .padding(.trailing, 24)
                .padding(.bottom, 6)
            
            ,alignment: .bottomTrailing)
        .padding(.leading, 12)
        .padding(.top, message.isSameIdAsPrevMessage ? 2 : 6)
        .padding(.bottom, message.isSameIdAsNextMessage ? 2 : 6)
        .onTapGesture {}
        .gesture(gesture)
        .frame(width: SCREEN_WIDTH)
        
    }
}

