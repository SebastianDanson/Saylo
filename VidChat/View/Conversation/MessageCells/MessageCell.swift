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
        VStack {
            if message.type == .Video, let urlString = message.videoUrl, let url = URL(string: urlString)  {
                VideoPlayerView(url: url, id: message.id)
            } else if message.type == .Audio, let urlString = message.videoUrl, let url = URL(string: urlString)  {
                AudioCell(audioURL: url)
            } else if message.type == .Text, let text = message.text {
                TextCell(text: text).frame(width: UIScreen.main.bounds.width)
            }
        }
    }
}
