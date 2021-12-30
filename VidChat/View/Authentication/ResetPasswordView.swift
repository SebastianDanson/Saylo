//
//  ResetPasswordView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//


import SwiftUI

struct ResetPasswordView: View {
    
    @State private var email = ""
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = AuthViewModel.shared
    
    var error: Error?
    
    var body: some View {
        
        let emailSentSuccessful = Alert(
            title: Text("Password Reset Email Sent"),
            message: Text("And email has been sent with instructions on how to reset your password"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    mode.wrappedValue.dismiss()
                }
            )
        )
        
        
        VStack {
            //email field
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Forgot Password?")
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
                
                
                //email field
                CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
                    .foregroundColor(.white)
                
                
                
                
            }.padding(.horizontal, 32)
            
            
            //forgot password
            
            
            //sign in
            
            NavigationLink(destination: RegistrationView(), isActive: $viewModel.canProceed) { EmptyView() }
            
            Button(action: {
                
                viewModel.resetPassword(withEmail: $email) { error in
                    if let error = error {
                        self.error = error
                        self.showErrorAlert = true
                    } else {
                        showSuccessAlert = true
                    }
                }
                
            }, label: {
                Text("Forgot Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 360, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(email.isEmpty ? 0.5 : 1)
            })
                .disabled(email.isEmpty)
                .alert(isPresented: $showErrorAlert) {
                    
                    Alert(
                        title: Text("Error"),
                        message: Text("\(error.localizedDescription ?? "")"),
                        dismissButton: .default(
                            Text("OK"),
                            action: {
                                
                            }
                        )
                    )
                }
                .alert(isPresented: $showSuccessAlert) {
                    emailSentSuccessful
                }
            
            Spacer()
            
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //TODO show loading indicator, after email is entered
}

