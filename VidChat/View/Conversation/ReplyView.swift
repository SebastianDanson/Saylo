//
//  ReplyView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct ReplyView: View {
    
    
    let isForTakingVideo: Bool
    
    var body: some View {
        
        ZStack {
            
            if isForTakingVideo == true {
                
                ZStack {
                    
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                    
                }
                .frame(width: 56, height: 56)
                .background(Color.init(white: 0, opacity: 0.4))
                .clipShape(Circle())
            }
        }
    }
}
