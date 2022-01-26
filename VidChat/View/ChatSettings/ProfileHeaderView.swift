//
//  ProfileHeaderView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    let authViewModel = AuthViewModel.shared
    
    let currentImage: String
    let userName: String
    
    @Binding var name: String
    
    @Binding var image: UIImage?
    @Binding var showSettings: Bool
    @Environment(\.presentationMode) var mode

    var body: some View {
        
        VStack {
            
            HStack {
                
                Button {
                    self.showSettings = false
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.systemBlue))
                        .padding(.leading, 16)
                }
                
                Spacer()
            }.frame(height: 44)
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else if currentImage != "" {
                KFImage(URL(string: currentImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else if let chat = ConversationViewModel.shared.chat{
                ChatImageCircle(chat: chat, diameter: 100)
            }
            
            Text(name)
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, userName.isEmpty ? 20 : 0)
            
            if !userName.isEmpty {
                
            Text(userName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.mainGray)
            }
        }
    }
}

