//
//  CreateChatCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-26.
//

import SwiftUI

struct CreateChatCell: View {
    
    let width = SCREEN_WIDTH/5.5
    let diameter: CGFloat = IS_SE ? 52 : 58
    
    var body: some View {
        
        ZStack {
            
            Color.systemWhite.ignoresSafeArea()
            
            HStack(alignment:.top, spacing: 14) {
                
                ZStack {
                    
                    Circle()
                        .strokeBorder(lineWidth: 3)
                        .foregroundColor(.createGroupBlue)
                        .frame(width: diameter, height: diameter)
                    
                    Image(systemName: "plus.bubble")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.createGroupBlue)
                        .frame(width: IS_SE ? 26 : 30, height: IS_SE ? 26 : 30)
                        .font(Font.title.weight(.semibold))
                    
                }
                
                VStack(alignment: .leading, spacing: IS_SMALL_PHONE ? 3 : 4) {
                    
                    Spacer()
                    
                    Text("Create a group")
                        .foregroundColor(.createGroupText)
                        .lineLimit(1)
                        .font(.system(size: IS_SMALL_PHONE ? 17 : 18, weight: .semibold))
                        
                    Spacer()
                }
                
                Spacer()
                
                
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, IS_SE ? 0 : (IS_SMALL_PHONE ? 2 : 6))
        .frame(width: SCREEN_WIDTH)
    }
}



