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
    
    @Binding var image: UIImage?
    @Binding var showSettings: Bool
    
    var body: some View {
        
        VStack {
            HStack {
               Spacer()
                
                Button {
                    self.showSettings = false
                } label: {
                    Text("Done")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                }

            }
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                KFImage(URL(string: currentImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Text("\(authViewModel.currentUser?.firstName ?? "") \(authViewModel.currentUser?.lastName ?? "")")
                .font(.system(size: 24, weight: .bold))
            
            Text("\(authViewModel.currentUser?.username ?? "")")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.mainGray)
        }
    }
}

