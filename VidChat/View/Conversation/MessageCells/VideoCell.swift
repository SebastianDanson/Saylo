//
//  VideoCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

struct VideoCell: View {
    
    @State var message: Message
    
    var body: some View {
        VStack {
            if let urlString = message.url, let url = URL(string: urlString) {
                VideoPlayerView(url: url)
            }
        }
    }
}
