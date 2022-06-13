//
//  SavedPopup.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct SavedPopUp: View {
    
    var body: some View {
        
        ZStack {
            
            Color.fadedBlack
            
            VStack {
                
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                
                Text("Saved")
                    .foregroundColor(.white)
                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                
            }
            
        }
        .frame(width: 100, height: 100)
        .cornerRadius(20)
        
    }
}
