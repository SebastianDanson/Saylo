//
//  VideoOptionsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-07-02.
//

import SwiftUI

struct VideoOptionsView: View {
    
    var body: some View {
        
        HStack {
            
            
            Button {

            } label: {
                Image(systemName: "bolt.slash")
                    .resizable()
                    .font(Font.title.weight(.semibold))
                    .scaledToFit()
                    .frame(height: 28)
                    .foregroundColor(.white)
                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
            }
            .frame(width: IS_SMALL_WIDTH ? 30 : 36, height: 31)
            
            Spacer()
            
            
            Button {
                MainViewModel.shared.cameraView.switchCamera()
            } label: {
                Image("multiCam")
                    .resizable()
                    .font(Font.title.weight(.semibold))
                    .scaledToFit()
                    .frame(height: 31)
                    .foregroundColor(.white)
                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
            }
            .frame(width: IS_SMALL_WIDTH ? 30 : 36, height: 31)
            .padding(.trailing, 1)
            
        }
        .frame(width: 180)
        
        
    }
    
}
