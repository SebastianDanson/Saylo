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
                
                HStack {
                    
                    Button {
                        withAnimation {
                            MainViewModel.shared.showCaption = false
                        }
                        selectedColor = .white
                        TextOverlayViewModel.shared.fontColor = .white
                        TextOverlayViewModel.shared.overlayText = ""
                    } label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .font(Font.system(size: 15, weight: .regular))
                    }


                    Spacer()
                    
                    Button {
                        withAnimation {
                            MainViewModel.shared.showCaption = false
                        }
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .font(Font.system(size: 15, weight: .semibold))
                    }

                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 12) {
                        
                        ForEach(Array(colors.enumerated()), id: \.1.hashValue) { i, color in
                            
                            Circle()
                                .frame(width: IS_SMALL_PHONE ? 44 : 48, height: IS_SMALL_PHONE ? 44 : 48)
                                .foregroundColor(color)
                                .onTapGesture {
                                    self.selectedColor = color
                                    TextOverlayViewModel.shared.fontColor = UIColor(color)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 4)
                
                Spacer()
            }
        }
        .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT - 16)
        .cornerRadius(16)
    }
}

