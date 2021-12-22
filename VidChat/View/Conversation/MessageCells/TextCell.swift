//
//  TextCell.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Foundation

struct TextCell: View {
    
    let text: String
    let messageId: String
    let isSameIdAsPrevMessage: Bool
    let date: Date
    @State var isSaved: Bool = false
    
    init(message: Message) {
        self.text = message.text ?? ""
        self.messageId = message.id
        self.isSameIdAsPrevMessage = message.isSameIdAsPrevMessage
        self.date = message.timestamp.dateValue()
        self.isSaved = message.isSaved
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !isSameIdAsPrevMessage {
                Image(systemName: "house")
                    .clipped()
                    .scaledToFit()
                    .padding()
                    .background(Color.gray)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sebastian")
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
        .padding(.vertical, 6)
        .onTapGesture {}
        .onLongPressGesture(perform: {
            withAnimation {
                if let i = ConversationViewModel.shared.messages
                    .firstIndex(where: {$0.id == messageId}) {
                    ConversationViewModel.shared.updateIsSaved(atIndex: i)
                    isSaved.toggle()
                }
            }
        })
        .frame(width: SCREEN_WIDTH)
        .overlay(
            ZStack {
                if isSaved {
                    
                    Button {
                        withAnimation {
                            
                        }
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
                    //Temp
                    
                }
            }
            ,alignment: .topTrailing)
    }
}

