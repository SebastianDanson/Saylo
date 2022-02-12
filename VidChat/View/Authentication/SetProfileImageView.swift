//
//  SetProfileImageView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-29.
//

import SwiftUI

struct SetProfileImageView: View {
    
    @State var profileImage: UIImage?
    @State var showLibraryImageCropper: Bool = false
    @State var showCameraImageCropper: Bool = false
    @State var showImagePicker: Bool = false
    @State var signUpComplete: Bool = false
    @State var showActionSheet: Bool = false
    @State var showCamera: Bool = false
    @State private var isLoading = false

    let cameraView = CameraMainView()
    
    var body: some View {
        
        ZStack {
            
            NavigationLink(destination: AllowNotificationsView().navigationBarHidden(true), isActive: $signUpComplete) { EmptyView() }

            VStack {
                
                Text("Adding a photo helps your friends recognize you")
                    .font(.system(size: 28, weight: .medium))
                
                
                Button {
                    
                    showActionSheet = true
                    
                } label: {
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .padding(.top, 40)
                    } else {
                        
                        Image("plusPhoto")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding(.top, 40)
                    }
                    
                }
                .actionSheet(isPresented: $showActionSheet, content: {
                    ActionSheet(title: Text("Select Photo Option"),
                                message: Text(""),
                                buttons: [
                                    .default(Text("Choose from library")) {
                                        showImagePicker = true
                                    },
                                    .default(Text("Take a photo")) {
                                        CameraViewModel.shared.isTakingPhoto = true
                                        CameraViewModel.shared.cameraView.setupProfileImageCamera()
                                        showCamera = true
                                    },
                                    .cancel()
                                ])
                })
                .sheet(isPresented: $showImagePicker, content: {
                    ImagePicker(image: $profileImage, showImageCropper: $showLibraryImageCropper)
                })
                
                
                Text("\(AuthViewModel.shared.currentUser?.firstName ?? "") \(AuthViewModel.shared.currentUser?.lastName ?? "")")
                    .font(.system(size: 24, weight: .medium))
                    .padding(.vertical)
                
                Spacer()
                
                Button {
                    
                    if let profileImage = profileImage {
//                        isLoading = true
                        AuthViewModel.shared.setProfileImage(image: profileImage) {
//                            isLoading = false
                        }
                        
                        signUpComplete = true

                    } else {
                        
                        DispatchQueue.main.async {
                            self.showActionSheet = true
                        }
                    }
                    
                } label: {
                    
                    Text(profileImage == nil ? "Add a profile Image" : "Continue")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: SCREEN_WIDTH * 0.75, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                    
                }.disabled(isLoading)
                
                if isLoading {
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 50, height: 50)
                        .padding(.top, -20)

                }
                
            }.padding(.bottom, BOTTOM_PADDING + 16)
            
            if showLibraryImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showLibraryImageCropper, showImagePicker: $showImagePicker)
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
            } else if showCameraImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showCameraImageCropper, showImagePicker: $showCamera)
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
            }
            
            
            if showCamera {
                
                CameraViewModel.shared.cameraView
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(6)
                    .overlay(
                        
                        VStack {
                            
                            HStack {
                                Spacer()
                                
                                Button {
                                    
                                    withAnimation {
                                        showCamera = false
                                    }
                                    
                                } label: {
                                    CameraOptionView(image: Image("x"), imageDimension: 14).padding()
                                }

                            }
                            
                            Spacer()
                            
                            Button(action: {
                                CameraViewModel.shared.takePhoto()
                                setImage()
                            }, label: {
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .padding(.bottom)
                            }) 
                        }.frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9).padding(.top, TOP_PADDING).ignoresSafeArea()
                        , alignment: .top)
                
            }
            
            
        }
        
        .navigationBarBackButtonHidden(true)
    }
    
    func setImage() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let photo = CameraViewModel.shared.photo {
                profileImage = photo
                showCameraImageCropper = true
                showCamera = false
            } else {
                setImage()
            }
        }
    }
}


