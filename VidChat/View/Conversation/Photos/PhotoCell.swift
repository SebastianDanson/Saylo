//
//  PhotoCell.swift
//  Saylo
//
//  Created by Student on 2021-10-15.
//

import SwiftUI

struct PhotoCell: View {
    
    let image: Image
    let width =  SCREEN_WIDTH / 4
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: width, height: width)
            .clipped()
    }
}

//struct PhotoCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoCell()
//    }
//}
