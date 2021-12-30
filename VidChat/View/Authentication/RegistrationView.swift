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
    @State private var showPassword = false
    @State private var showAlert = false

    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = AuthViewModel.shared
    
    var body: some View {
                
        let invalidEmailAlert = Alert(
            title: Text("Please enter a valid email"),
            message: nil,
            dismissButton: .default(
                Text("OK"),
                action: {
                  
                }
            )
        )
        
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
                    
                    
                    //                    CustomTextField(text: $userName, placeholder: Text("Username"), imageName: "person")
                    //                        .foregroundColor(.white)
                    
                    //password field
                    
                    if showPassword {
                        CustomSecureField(text: $password)
                            .foregroundColor(.white)
                    }
                    
                    
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
                    
                    if !showPassword {
                        if isValidEmail(email) {
                            withAnimation {
                                showPassword = true
                            }
                        } else {
                            showAlert = true
                        }
                    } else {
                        viewModel.canProceed = true
                        viewModel.register(withEmail: email, password: password, userName: userName)
                    }
                    
                }, label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                        .opacity(email.isEmpty ? 0.5 : 1)
                })
                    .disabled(email.isEmpty)
                    .alert(isPresented: $showAlert) {
                    invalidEmailAlert
                }
                
                Spacer()
                
            }
        }
        .padding(.top, -44)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //TODO show loading indicator, after email is entered
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
