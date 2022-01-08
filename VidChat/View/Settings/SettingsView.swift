//
//  SettingsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

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
                    ConversationGridViewModel.shared.showSettingsView = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        AuthViewModel.shared.logout()
                    }
                }
            )
        )
        
        VStack(spacing: 0) {
            
            Button {
                showImagePicker = true
            } label: {
                SettingsCell(imageName: "person.fill", imageColor: .mainBlue, title: "Edit Profile Image")
            }.sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: $profileImage, showImageCropper: $showImageCropper)
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
        .background(Color.popUpSystemWhite)
        .ignoresSafeArea()
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
                    .foregroundColor(.systemWhite)
                    .frame(width: 17, height: 17)
                
            }.padding(.leading)
            
            Text(title).foregroundColor(.systemBlack)
            
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


