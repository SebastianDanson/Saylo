//
//  LoadingVideoView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct LoadingVideoView: View {
    
    //need this to be able to use reader.scroll to
    var arrayOfOne = ["test"]
    var reader: ScrollViewProxy
    
    var body: some View {
        
        ForEach(Array(arrayOfOne.enumerated()), id: \.1) { i, id in
            ZStack {
                
                Color.init(white: 0.1)
                
                CircularLoadingAnimationView(dimension: MINI_MESSAGE_WIDTH / 1.3)
                
            }
            .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
            .cornerRadius(6)
            .onAppear {
                withAnimation {
                    reader.scrollTo(id, anchor: .trailing)
                }
            }
        }
    }
}
