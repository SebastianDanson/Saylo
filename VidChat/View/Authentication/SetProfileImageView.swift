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
    
    let cameraView = MainView()
    
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
                                        //                                        MainViewModel.shared.isTakingPhoto = true
//                                        MainViewModel.shared.cameraView.setupProfileImageCamera()
                                        showCamera = true
                                        showImagePicker = true
                                    },
                                    .cancel()
                                ])
                })
                .sheet(isPresented: $showImagePicker, content: {
                    if showCamera {
                        ZStack {
                            
                            PhotoCamera(image: $profileImage, showImageCropper: $showCameraImageCropper, showCamera: $showCamera)
                              
                            
                            VStack {
                                
                                HStack {
                                    
                                    Button(action: {
                                        withAnimation {
                                            showCamera = false
                                        }
                                    }, label: {
                                        
                                        ZStack {
                                            
                                            Circle()
                                                .foregroundColor(.fadedBlack)
                                                .frame(width: 36, height: 36)
                                            
                                            Image("x")
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .frame(width: 22, height: 22)
                                            
                                        }
                                        .padding(16)
                                    })
                                    
                                    Spacer()
                                    
                                }
                                
                                Spacer()
                            }
                        }
                    } else {
                        ImagePicker(image: $profileImage, showImageCropper: $showLibraryImageCropper, showPhotoLibrary: true)
                    }
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
                            self.showImagePicker = true
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
                ImageCropper(image: $profileImage, showImageCropper: $showLibraryImageCropper, showImagePicker: $showImagePicker, showCamera: $showCamera)
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
            } else if showCameraImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showCameraImageCropper, showImagePicker: $showCamera, showCamera: $showCamera)
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
            }
            
            
           
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func setImage() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let photo = MainViewModel.shared.photo {
                profileImage = photo
                showCameraImageCropper = true
                showCamera = false
            } else {
                setImage()
            }
        }
    }
}


