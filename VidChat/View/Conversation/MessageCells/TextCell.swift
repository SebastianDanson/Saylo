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
        .padding(.vertical, 4)
        .onTapGesture {}
        .onLongPressGesture(perform: {
            withAnimation {
                if let i = ConversationViewModel.shared.messages
                    .firstIndex(where: {$0.id == messageId}) {
                    ConversationViewModel.shared.messages[i].isSaved.toggle()
                    isSaved.toggle()
                }
            }
        })
        .frame(width: SCREEN_WIDTH)
        .overlay(
            ZStack {
                if isSaved {
                    Image(systemName: "bookmark.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.mainBlue)
                        .frame(width: 36, height: 24)
                        .padding(.leading, 8)
                        .transition(.scale)
                }
            }
            ,alignment: .topTrailing)
    }
}

