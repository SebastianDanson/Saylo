//
//  ProfileView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ProfileView: View {
        
    
    @Binding var showSettings: Bool

    @State var profileImage: UIImage?
    @State var showImageCropper = false
    @State var showImagePicker = false
    
    let currentUser = AuthViewModel.shared.currentUser

    init(showSettings: Binding<Bool>) {
        self._showSettings = showSettings
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 32) {
                    
                    ProfileHeaderView(currentImage: currentUser?.profileImage ?? "", userName: currentUser?.username ?? "",
                                      name: .constant((currentUser?.firstName ?? "") + " " + (currentUser?.lastName ?? "")),
                                      image: $profileImage)
                    

                    SettingsView(profileImage: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
                    
                }
            }
            .padding(.top)
            
            if showImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker, onDone: {
                    
                    if let profileImage = profileImage {
                        AuthViewModel.shared.updateProfileImage(image: profileImage)
                    }
                })
                    .ignoresSafeArea()
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
            
        }.background(Color.backgroundGray)
    }
}


struct DividerView: View {
    
    var body: some View {
        
        HStack {
            Spacer()
            Rectangle()
                .foregroundColor(.dividerGray)
                .frame(width: SCREEN_WIDTH - 102, height: 0.5)
        }
    }
}
