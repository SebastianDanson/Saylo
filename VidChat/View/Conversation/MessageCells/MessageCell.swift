//
//  MessageCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

struct MessageCell: View {
    
    @State var message: Message
    
    var body: some View {
        ZStack {
            if message.type == .Video, let urlString = message.url, let url = URL(string: urlString)  {
                VideoPlayerView(url: url, id: message.id, isSaved: message.isSaved, showName: true)
            } else if message.type == .Audio, let urlString = message.url, let url = URL(string: urlString)  {
                AudioCell(audioURL: url)
            } else if message.type == .Text, let text = message.text {
                TextCell(text: text, messageId: message.id, isSaved: message.isSaved)
                    
            } else if message.type == .Photo {
                if let image = message.image {
                    ImageCell(url: nil, image: Image(uiImage: image), messageId: message.id, isSaved: message.isSaved)
                } else {
                    ImageCell(url: message.url, image: nil, messageId: message.id, isSaved: message.isSaved)
                }
            }
        }
    }
}
