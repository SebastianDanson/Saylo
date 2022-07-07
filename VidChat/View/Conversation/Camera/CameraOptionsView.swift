//
//  VideoOptionsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-07-02.
//

import SwiftUI

struct VideoOptionsView: View {
    
    @Binding var isMultiCamEnabled: Bool
//    @Binding var isRecording: Bool

    var body: some View {
        
        HStack {
            
//            if !isMultiCamEnabled && !isRecording {
                
//                Button {
//
//                } label: {
//                    Image(systemName: "bolt.slash")
//                        .resizable()
//                        .font(Font.title.weight(.semibold))
//                        .scaledToFit()
//                        .frame(height: 28)
//                        .foregroundColor(.white)
//                        .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
//                        .padding(.horizontal, 10)
//                }
//                .padding(.horizontal, 10)
                
//            }
            
            Spacer()
            
            
            Button {
                MainViewModel.shared.cameraView.toggleMultiCamera()
            } label: {
                Image("multiCam")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(height: 31)
                    .foregroundColor(isMultiCamEnabled ? Color(.systemBlue) : .white)
                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                    .padding(.horizontal, 10)
            }
        }
        .frame(width: 180)
        
    }
}
