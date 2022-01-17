//
//  SetUsernameView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-30.
//

import SwiftUI

struct SetUsernameView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var username = ""
    @State private var nameEntered = false
    @State private var showInvalidUsername = false
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        
        let invalidUsernameAlert = Alert(
            title: Text("Your username must be under 50 characters"),
            message: nil,
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        let usernameTakenAlert = Alert(
            title: Text("This username is already taken"),
            message: Text("Please enter a different username"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        VStack {
            
            //email field
            
            VStack(spacing: 24) {
                
                VStack(alignment: .center, spacing: 4) {
                    
                    Text("Set your username")
                        .font(.system(size: 30, weight: .medium))
                    
                    
                    Text("Your username should be at least 4\ncharacters")
                        .font(.system(size: 18, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.mainGray)
                        .padding(.vertical, 4)
                    
                }.padding(.bottom, 6)
                
                
                //Username field
                
                CustomTextField(text: $username, placeholder: Text("Username"), imageName: "person", allowSpaces: false)
                    .foregroundColor(.systemWhite)
                    .padding(.top, 2)
                    .padding(.bottom)
                    .padding(.horizontal)
                
            }.padding(.horizontal, 32)
            
            
            NavigationLink(destination: SetProfileImageView(), isActive: $nameEntered) { EmptyView() }
            
            
            Button(action: {
                
                if username.count >= 50  {
                    showInvalidUsername = true
                } else if !username.isEmpty {
                    
                    isLoading = true
                                        
                    
                    viewModel.setUsername(username: username.trimmingCharacters(in: .whitespacesAndNewlines)) { alreadyTaken in
                        
                        if alreadyTaken {
                            showInvalidUsername = false
                            showError = true
                        } else {
                            nameEntered = true
                        }
                        
                        isLoading = false
                    }
                }
                
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(username.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 ? 0.5 : 1)
            })
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).count < 4)
                .padding(.vertical, 20)
                .alert(isPresented: $showError) {
                    
                    if showInvalidUsername {
                        return invalidUsernameAlert
                    } else {
                        return usernameTakenAlert
                    }
                }
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
                
            }
            
            Spacer()
            
        }.navigationBarBackButtonHidden(true)
    }
}


