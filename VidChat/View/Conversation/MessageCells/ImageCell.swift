//
//  ImageCell.swift
//  VidChat
//
//  Created by Student on 2021-10-19.
//

import SwiftUI
import Kingfisher

struct ImageCell: View {
    
    let url: String?
    let image: Image?
    
    var body: some View {
        
        if let url = url {
            KFImage(URL(string: url))
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
        } else if let image = image {
            image
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width)
                .clipped()
        }
       
        
        //TODO set max height for images
    }
}

