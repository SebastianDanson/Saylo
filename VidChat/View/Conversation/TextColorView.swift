//
//  TextColorView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-05-12.
//

import SwiftUI

struct TextColorView: View {
    
    @State var colors = [Color.white, Color(.systemBlue), Color(.systemPurple), Color(.systemRed), Color(.systemGreen), Color(.systemYellow), Color.black]
    @Binding var selectedColor: Color
    
    var body: some View {
        
        ZStack {
            
            Color.darkgray
            
            VStack {
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 12) {
                        
                        ForEach(Array(colors.enumerated()), id: \.1.hashValue) { i, color in
                            
                            Circle()
                                .frame(width: 48, height: 48)
                                .foregroundColor(color)
                                .onTapGesture {
                                    self.selectedColor = color
                                    TextOverlayViewModel.shared.fontColor = UIColor(color)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .cornerRadius(16)
        .padding(.vertical)
    }
}

