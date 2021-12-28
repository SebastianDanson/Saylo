//
//  ProfileHeaderView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var image: UIImage?
    @Binding var showSettings: Bool

    let profileImage = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%202.54.09%20PM.png?alt=media&token=0a1b499c-a2d9-416f-ab99-3f965939ed66"
    
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
                KFImage(URL(string: viewModel.user.image))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Text("\(viewModel.user.firstname) \(viewModel.user.lastname)")
                .font(.system(size: 24, weight: .bold))
        }
    }
}

