//
//  LastSeenProfileImageView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI
import Kingfisher

struct LastSeenProfileImageView: View {
    
    var profileImages: [String]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Spacer()
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 2) {
                    
                    ForEach(0..<min(profileImages.count, 2), id: \.self) { i in
                        
                        KFImage(URL(string: profileImages[i]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: IS_SMALL_WIDTH ? 24 : 26, height: IS_SMALL_WIDTH ? 24 : 26)
                            .clipShape(Circle())
                    }                    
                }
            }
            .frame(width: MINI_MESSAGE_WIDTH - 6)
            
        }
        .padding(.bottom, 3)
        .padding(.horizontal, 3)
    
    }
}

