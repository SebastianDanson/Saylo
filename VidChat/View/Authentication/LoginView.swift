//
//  LoginView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var canProceed = false
    @State private var showForgotPassword = false
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false

    @StateObject var viewModel = AuthViewModel.shared
    
    var body: some View {
        
        VStack {
            //email field
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Login")
                        .font(.system(size: 30, weight: .medium))
                    
                    NavigationLink(
                        destination: RegistrationView().navigationBarBackButtonHidden(true),
                        label: {
                            Text("or ").foregroundColor(.black) +
                            
                            Text("Sign up")
                                .foregroundColor(.mainBlue)
                                .fontWeight(.medium)
                        })
                    
                    
                }.padding(.bottom, 6)
                
                
                CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
                    .foregroundColor(.white)
                
                //password field
                
                CustomSecureField(text: $password)
                    .foregroundColor(.white)
            }.padding(.horizontal, 32)
            
            
            //forgot password
            
            HStack {
                
                Button(action: {
                    
                        showForgotPassword = true
                    
                    }, label: {
                        
                        Text("Forgot Password?")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.mainGray)
                            .padding(.vertical, 4)
                            .padding(.trailing, 28)
                        
                    }).sheet(isPresented: $showForgotPassword) {
                        ResetPasswordView().navigationBarBackButtonHidden(true)
                    }
                
                Spacer()
                
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 32)
            
            //sign in
            
            NavigationLink(destination: ConversationGridView().navigationBarBackButtonHidden(true), isActive: $canProceed) { EmptyView() }
            
            Button(action: {
                
                isLoading = true
                
                viewModel.login(withEmail: email, password: password) { error in
                    
                    isLoading = false
                    
                    if let error = error {
                        self.error = error
                        showError = true
                    } else {
                        canProceed = true
                    }
                }
                
            }, label: {
                
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 64, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(password.isEmpty || email.isEmpty ? 0.5 : 1)
                
            })
                .disabled(password.isEmpty || email.isEmpty)
                .alert(isPresented: $showError) {
                    
                 Alert(
                    title: Text("Error"),
                    message: Text("\(error?.localizedDescription ?? "")"),
                    dismissButton: .default(
                        Text("OK"),
                        action: {
                            self.error = nil
                        }
                    )
                )
            }
            
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
                
            }
            
            Spacer()
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

