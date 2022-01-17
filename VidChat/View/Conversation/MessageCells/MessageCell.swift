//
//  MessageCell.swift
//  Saylo
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

struct MessageCell: View {
    
    var message: Message
    
    
    var body: some View {
        ZStack {
            if message.type == .Video {
                VideoCell(message: message)
            } else if message.type == .Audio, let urlString = message.url, let url = URL(string: urlString)  {
                AudioCell(message: message, audioUrl: url)
//                VideoCell(message: message)

            } else if message.type == .Text {
                TextCell(message: message)
            } else if message.type == .Photo {
                if let image = message.image {
                    ImageCell(message: message, url: nil, image: image, showName: true)
                } else {
                    ImageCell(message: message, url: message.url, image: nil, showName: true)
                }
            }
        }
    }
}
