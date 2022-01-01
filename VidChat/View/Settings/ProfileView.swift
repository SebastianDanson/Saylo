//
//  ProfileView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ProfileView: View {
    
    let user: TestUser
    
    @ObservedObject var viewModel: ProfileViewModel
    
    @Binding var showSettings: Bool

    @State var profileImage: UIImage?
    @State var showImageCropper = false
    @State var showImagePicker = false

    init(user: TestUser, showSettings: Binding<Bool>) {
        self.user = user
        self.viewModel = ProfileViewModel(user: user)
        self._showSettings = showSettings
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 32) {
                    
                    ProfileHeaderView(viewModel: viewModel, image: $profileImage, showSettings: $showSettings)
                    
                    SettingsView(profileImage: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
                    
                }
            }
            .padding(.top)
            
            if showImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
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
