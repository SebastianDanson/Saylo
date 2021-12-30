//
//  SetProfileImageView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//

import SwiftUI

struct SetProfileImageView: View {
    
    @State var profileImage: UIImage?
    @State var showImageCropper: Bool = false
    @State var showImagePicker: Bool = false
    @State var signUpComplete: Bool = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                NavigationLink(destination: ConversationGridView(), isActive: $signUpComplete) { EmptyView() }
                
                VStack {
                    
                    Text("Adding a photo helps your friends recognize you")
                        .font(.system(size: 28, weight: .medium))
                        .padding(.top, TOP_PADDING)
                    
                    
                    Button {
                        
                        showImagePicker = true
                        
                    } label: {
                        
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .padding(.top, 40)
                                .clipShape(Circle())
                        } else {
                            
                            Image("plusPhoto")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .padding(.top, 40)
                        }
                        
                    }.sheet(isPresented: $showImagePicker, content: {
                        ImagePicker(image: $profileImage, showImageCropper: $showImageCropper)
                    })
                    
                    
                    Text("Seb Danson")
                        .font(.system(size: 24, weight: .medium))
                        .padding(.vertical)
                    
                    Spacer()
                    
                    
                    Button {
                        
                        if profileImage != nil {
                            signUpComplete = true
                        } else {
                            showImagePicker = true
                        }
                        
                    } label: {
                        
                        Text(profileImage == nil ? "Add a profile Image" : "Continue")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: SCREEN_WIDTH * 0.75, height: 50)
                            .background(Color.mainBlue)
                            .clipShape(Capsule())
                        
                    }
                    
                }.padding(.vertical, BOTTOM_PADDING + 16)
                
                if showImageCropper {
                    ImageCropper(image: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker)
                        .zIndex(5)
                        .transition(.move(edge: .bottom))
                        .ignoresSafeArea()
                }
            }
            
            .navigationBarHidden(true)
        }
    }
}

