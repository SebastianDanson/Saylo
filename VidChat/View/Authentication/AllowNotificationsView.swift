//
//  AllowNotificationsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-02-10.
//

import Foundation
import SwiftUI

struct AllowNotificationsView: View {
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                Text("Last step! Allow notifications\nto know when you have a message")
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, TOP_PADDING + 60)
                    .foregroundColor(.white)
                
                Text("Saylo is a messaging service, so it \ndoesn't really work without this :)")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                Image("AllowNotifications")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270, height: 180)
                    .overlay(
                        
                        Circle().stroke(Color(.systemBlue), lineWidth: 4)
                            .frame(width: 64, height: 64)
                            .padding(.trailing, 40)
                            .padding(.bottom, -8)
                            .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true))
                            .transition(.opacity), alignment: .bottomTrailing
                    )
                
                Spacer()
                
            }
            
        }
        .frame(width: SCREEN_WIDTH)
        .edgesIgnoringSafeArea(.all)
        .background(Color.mainBlue)
    }
    
}
