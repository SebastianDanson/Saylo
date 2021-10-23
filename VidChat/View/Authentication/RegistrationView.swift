//
//  RegistrationView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var userName = ""
    @State private var fullName = ""
    @State private var password = ""
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                //email field
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sign up")
                            .font(.system(size: 30, weight: .medium))
                        
                        NavigationLink(
                            destination: LoginView().navigationBarHidden(true),
                            label: {
                                Text("or ").foregroundColor(.black) +
                                
                                Text("Login")
                                    .foregroundColor(.mainBlue)
                                    .fontWeight(.medium)
                            })
                        
                        
                    }.padding(.bottom, 6)
                    
                    
                    CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
                        .foregroundColor(.white)
                    
                    
                    CustomTextField(text: $userName, placeholder: Text("Username"), imageName: "person")
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
                
                Button(action: { viewModel.register(withEmail: email, password: password, userName: userName) }, label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                })
                
                Spacer()
                
            }
        }
        .padding(.top, -44)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
