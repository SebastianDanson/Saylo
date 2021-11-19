//
//  ImageCell.swift
//  VidChat
//
//  Created by Student on 2021-10-19.
//

import SwiftUI
import Kingfisher

struct ImageCell: View {
    
    let url: String?
    let image: Image?
    let messageId: String
    @State var isSaved: Bool
    
    
    var body: some View {
        
      //  ZStack {
            if let url = url {
                KFImage(URL(string: url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            } else if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            }
      //  }
//        onTapGesture {}
//        .onLongPressGesture(perform: {
//            withAnimation {
//                if let i = ConversationViewModel.shared.messages
//                    .firstIndex(where: {$0.id == messageId}) {
//                    ConversationViewModel.shared.messages[i].isSaved.toggle()
//                    isSaved.toggle()
//                }
//            }
//        })
//        .frame(width: SCREEN_WIDTH)
//        .overlay(
//            ZStack {
//                if isSaved {
//                    Image(systemName: "bookmark.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(.mainBlue)
//                        .frame(width: 36, height: 24)
//                        .padding(.leading, 8)
//                        .transition(.scale)
//                }
//            }
//            ,alignment: .topTrailing)
        
        
        //TODO set max height for images
    }
}

