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
    
    @State var profileImage: UIImage?
    @State var showImageCropper = false
    @State var showImagePicker = false

    init(user: TestUser) {
        self.user = user
        self.viewModel = ProfileViewModel(user: user)
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 32) {
                    
                    ProfileHeaderView(viewModel: viewModel, image: $profileImage)
                    
                    SettingsView(profileImage: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
                    
                }
            }
            .padding(.top)
            
            if showImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}


struct SettingsView: View {
    
    @Binding var profileImage: UIImage?
    @Binding var showImageCropper: Bool
    @Binding var showImagePicker: Bool
    
    @State var showLogoutAlert = false
    @State var showContactUs = false

    var body: some View {
        
        let logoutAlert = Alert(
            title: Text("Are you sure you want to logout?"),
            message: nil,
            primaryButton: .default(
                Text("Cancel"),
                action: {
                  
                }
            ),
            secondaryButton: .destructive(
                Text("Logout"),
                action: {
                    //TODO handle logout
                }
            )
        )
        
        VStack(spacing: 0) {
            
            Button {
                showImagePicker = true
            } label: {
                SettingsCell(imageName: "person.fill", imageColor: .mainBlue, title: "Edit Profile Image")
            }.sheet(isPresented: $showImagePicker, onDismiss: {
                showImageCropper = true
            }, content: {
                ImagePicker(image: $profileImage)
            })
            
            
            DividerView()
            
            Button {
                showContactUs = true
            } label: {
                SettingsCell(imageName: "envelope.fill", imageColor: Color(.systemGreen), title: "Contact Us")
            }.sheet(isPresented: $showContactUs, content: {
                ContactUsView()
            })


            
            DividerView()
            
            Button {
                showLogoutAlert = true
            } label: {
                SettingsCell(imageName: "rectangle.portrait.and.arrow.right.fill", imageColor: Color(.systemGray), title: "Logout")
            }.alert(isPresented: $showLogoutAlert) {
                logoutAlert
            }

            
        }
        .frame(width: SCREEN_WIDTH - 40)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color(.init(white: 0, alpha: 0.04)), radius: 16, x: 0, y: 4)
        
    }
}

struct SettingsCell: View {
    
    let imageName: String
    let imageColor: Color
    let title: String
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            ZStack {
                
                Circle()
                    .frame(width: 32, height: 32)
                    .foregroundColor(imageColor)
                
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 17, height: 17)
                
            }.padding(.leading)
            
            Text(title).foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .foregroundColor(.chevronGray)
                .frame(width: 15, height: 15)
                .padding(.horizontal, 12)
            
        }.frame(height: 50)
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
