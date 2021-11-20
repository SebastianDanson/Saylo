//
//  MessageCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

struct MessageCell: View {
    
    @State var message: Message
    
        //TODO add time stamps for images and audio cells
    
    var body: some View {
        ZStack {
            if message.type == .Video, let urlString = message.url, let url = URL(string: urlString)  {
                VideoPlayerView(url: url, id: message.id, isSaved: message.isSaved, showName: true,
                                date: message.timestamp.dateValue())
            } else if message.type == .Audio, let urlString = message.url, let url = URL(string: urlString)  {
                AudioCell(audioURL: url, date: message.timestamp.dateValue())
            } else if message.type == .Text {
                TextCell(message: message)
            } else if message.type == .Photo {
                if let image = message.image {
                    ImageCell(url: nil, image: image, messageId: message.id, showName: true, date: message.timestamp.dateValue(), isSaved: message.isSaved)
                } else {
                    ImageCell(url: message.url, image: nil, messageId: message.id, showName: true, date: message.timestamp.dateValue(), isSaved: message.isSaved)
                }
            }
        }
    }
}
