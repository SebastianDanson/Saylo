//
//  CallEndedView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct CallEndedView: View {
    
    let isLarge: Bool
    
    var body: some View {
        
        VStack(spacing: isLarge ? 24 : 8){
            
            Image("video")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: isLarge ? SCREEN_WIDTH/5 : MINI_MESSAGE_WIDTH/3)
                .padding(.leading, isLarge ? 4 : 1)
            
            Text("Ended")
                .foregroundColor(.white)
                .font(Font.system(size: isLarge ? 32 : 16, weight: .semibold, design: .rounded))
            
        }
        .frame(width: isLarge ? SCREEN_WIDTH : MINI_MESSAGE_WIDTH, height: isLarge ? MESSAGE_HEIGHT : MINI_MESSAGE_HEIGHT)
        .background(Color(white: 0.2))
        
    }
}
