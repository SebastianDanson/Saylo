//
//  FindFiendsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct FindFiendsView: View {
        
    var body: some View {
        
        VStack(spacing: 20) {
            
            VStack(spacing: 4) {
                
                Text("Welcome to Vidchat")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 15)
                
                Text("Add friends and family to start chatting")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textGray)
                
            }
            
            Button {
                
            } label: {
                
                Text("Find Friends")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 28)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                
            }.padding(.bottom, 15)
            
        }
        .frame(width: SCREEN_WIDTH - 40, height: 150)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.vertical, 28)
        .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
        
    }
}

