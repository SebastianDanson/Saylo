//
//  TextCell.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI

struct TextCell: View {
    
    let text: String
    let messageId: String
    @State var isSaved: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "house")
                .clipped()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Sebastian")
                    .font(.system(size: 14, weight: .semibold))
                Text(text)
                    .font(.system(size: 16))
            }
            Spacer()
        }
        .background(Color.white)
        .padding(.horizontal)
        .padding(.vertical, 2)
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

