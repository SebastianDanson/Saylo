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
                                
                Spacer()
                
                //                ScrollView(.horizontal, showsIndicators: false) {
                
                let spacing: CGFloat = IS_SMALL_WIDTH ? 10 : 12
                let offset: CGFloat = CGFloat((filters.count)) * spacing + 28
                let width: CGFloat = (SCREEN_WIDTH - offset)/CGFloat((filters.count + 1))
                
                HStack(spacing: spacing) {
                    
                    Button {
                        ConversationViewModel.shared.selectedFilter = nil
                    } label: {
                        
                        VStack(spacing: 4) {
                        
                        Image("filterBackgroundNormal")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width , height: max(width,MINI_MESSAGE_HEIGHT * 0.7))
                            .cornerRadius(6)
                            
                            Text("natural")
                                .foregroundColor(.white)
                                .font(Font.system(size: 13, weight: .medium, design: .rounded))
                        }
                    }
                    
                    ForEach(Array(filters.enumerated()), id: \.1.hashValue) { i, filter in
                        
                        
                        Button {
                            ConversationViewModel.shared.selectedFilter = filter
                        } label: {
                            VStack(spacing: 4) {
                                                                
                                Image(filter.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width , height: max(width,MINI_MESSAGE_HEIGHT * 0.7))
                                    .cornerRadius(6)
                                
                
                                Text(filter.name)
                                    .foregroundColor(.white)
                                    .font(Font.system(size: 13, weight: .medium, design: .rounded))
//
                            }
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
                .padding(.horizontal, 14)
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
