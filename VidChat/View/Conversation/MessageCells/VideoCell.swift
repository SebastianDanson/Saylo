//
//  VideoCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

//TODO fix issue when you close camera and u see the whit background of text cell i.e have textcell on screen and open and close camera

struct VideoCell: View {
    
    @State var message: Message
    
    var body: some View {
        GeometryReader { geometry in

        VStack {
            if let urlString = message.url, let url = URL(string: urlString) {
            //    VideoPlayerView(url: url)
            }
        }
        }
    }
    
    private func isButtonHidden(_ geometry: GeometryProxy) -> Bool {
    // Alternatively, you can also check for geometry.frame(in:.global).origin.y if you know the button height.
                if geometry.frame(in: .global).maxY <= 0 {
                    return true
                }
                return false
            }
}
