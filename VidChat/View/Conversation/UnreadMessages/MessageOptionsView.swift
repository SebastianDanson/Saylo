//
//  MessageOptionsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-28.
//

import SwiftUI
import Kingfisher

struct MessageOptionsView: View {
    
    let lineGray = Color(red: 220/255, green: 220/255, blue: 220/255)
    
    var body: some View {
        
        
        VStack(spacing: 20) {
            
            Spacer()
            
            VStack {
                
                HStack(spacing: 20) {
                    
                    KFImage(URL(string: "https://firebasestorage.googleapis.com:443/v0/b/vidchat-12c32.appspot.com/o/profileImages%2F27684953-471A-480D-AAB4-4C2F1D7208B2?alt=media&token=ae19f4db-dc0e-419b-84d6-d8df45d569b3"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    
                    Text("Age")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(width: SCREEN_WIDTH, height: 1)
                    .foregroundColor(lineGray)
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.black)
                    }
                    .frame(width: 32, height: 32)
                    
                    Text("7:52 PM")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 22)
                            .foregroundColor(.black)
                    }
                    .frame(width: 32, height: 32)
                    
                    Text("Seen by Seb and Mom")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    
                    Spacer()
                }
                
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.black)
                    }
                    .frame(width: 32, height: 32)
                    
                    Text("No Reactions")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(width: SCREEN_WIDTH, height: 1)
                    .foregroundColor(lineGray)
                
                HStack {
                    
                    VStack {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color(.systemRed))
                        
                        Text("Delete")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(.systemRed))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color(.systemBlue))
                        
                        Text("Save")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(.systemBlue))
                    }
                }
                
            }
            .padding()
            .frame(width: SCREEN_WIDTH)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
     
        }
        .padding(.bottom, BOTTOM_PADDING)
        .ignoresSafeArea(edges: [.bottom])
    }
}

struct MessageOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MessageOptionsView()
    }
}
