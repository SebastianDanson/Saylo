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
    @StateObject var viewModel = AuthViewModel.shared

    var body: some View {
        NavigationView {
            VStack {
                //email field
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Login")
                            .font(.system(size: 30, weight: .medium))
                        
                        NavigationLink(
                            destination: RegistrationView().navigationBarHidden(true),
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
                    Spacer()
                    NavigationLink(
                        destination: ResetPasswordView(email: $email),
                        label: {
                            Text("Forgot Password?")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.top)
                                .padding(.trailing, 28)
                        })
                }
                
                //sign in
                
                NavigationLink(destination: RegistrationView(), isActive: $viewModel.canProceed) { EmptyView() }

                Button(action: {
                    viewModel.login(withEmail: email, password: password)
                    viewModel.canProceed = true
                }, label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                })
                
                Spacer()
                //go to sign up
                
            }
            
        }
        .padding(.top, -44)
    }
}

