//
//  LoadingVideoView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct LoadingVideoView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.init(white: 0.1)
            
            CircularLoadingAnimationView(dimension: MINI_MESSAGE_WIDTH / 1.3)
            
        }
        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
        .cornerRadius(6)
        
    }
}
