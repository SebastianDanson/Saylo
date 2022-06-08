//
//  FiltersView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-07.
//

import SwiftUI

struct FiltersView: View {
    
    var filters = Filter.allCases
    
    var body: some View {
        ZStack {
            
            Color.darkgray
            
            VStack {
                
                HStack {
                    
                    Button {
                        withAnimation {
                            MainViewModel.shared.showFilters = false
                        }
                    } label: {
                        Text("Clear")
                            .foregroundColor(.white)
                            .font(Font.system(size: 15, weight: .regular))
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            MainViewModel.shared.showFilters = false
                        }
                    } label: {
                        Text("Done")
                            .foregroundColor(.white)
                            .font(Font.system(size: 15, weight: .semibold))
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 6)
                
                
                
                //                ScrollView(.horizontal, showsIndicators: false) {
                
                let spacing: CGFloat = IS_SMALL_WIDTH ? 12 : 14
                let offset: CGFloat = CGFloat((filters.count-1)) * spacing + 32
                let width: CGFloat = (SCREEN_WIDTH - offset)/CGFloat((filters.count))
                
                HStack(spacing: spacing) {
                    
                    ForEach(Array(filters.enumerated()), id: \.1.hashValue) { i, filter in
                        
                        
                        VStack(spacing: 4) {
                            
                            Image("filterBackgroundSmall")
                                .resizable()
                                .scaledToFill()
                                .frame(width: width , height: max(width,MINI_MESSAGE_HEIGHT * 0.55))
                                .cornerRadius(6)
                            
                            Text(filter.name)
                                .foregroundColor(.white)
                                .font(Font.system(size: 12, weight: .medium, design: .rounded))
                            
                        }
                        
                        
                        //                            Circle()
                        //                                .frame(width: IS_SMALL_PHONE ? 44 : 48, height: IS_SMALL_PHONE ? 44 : 48)
                        //                                .foregroundColor(color)
                        //                                .onTapGesture {
                        //                                    self.selectedColor = color
                        //                                    TextOverlayViewModel.shared.fontColor = UIColor(color)
                        //                                }
                    }
                }
                .padding(.horizontal, 16)
                //                }
                
                Spacer()
            }
        }
        .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT)
        .cornerRadius(16)
    }
}

struct FiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FiltersView()
    }
}
