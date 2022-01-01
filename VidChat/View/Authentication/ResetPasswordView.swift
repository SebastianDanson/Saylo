//
//  ResetPasswordView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//


import SwiftUI

struct ResetPasswordView: View {
    
    @State private var email = ""
    @State private var showAlert = false
    @State var error: Error?
    
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = AuthViewModel.shared
    
    
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
                    
                    Text("Reset Password")
                        .font(.system(size: 30, weight: .medium))
                        .padding(.top, 44)
                    
                    
                }.padding(.bottom, 6)
                
                
                //email field
                CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
                    .foregroundColor(.white)
                    .padding(.bottom, 24)
                
                
                
                
            }.padding(.horizontal, 32)
            
            
            //forgot password
            
            
            //sign in
                        
            Button(action: {
                
                viewModel.resetPassword(withEmail: email) { error in
                    self.error = error
                    showAlert = true
                }
                
            }, label: {
                Text("Forgot Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 64, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(email.isEmpty ? 0.5 : 1)
            })
                .disabled(email.isEmpty)
                .alert(isPresented: $showAlert) {
                    
                    if let error = error {
                        return Alert(
                            title: Text("Error"),
                            message: Text("\(error.localizedDescription)"),
                            dismissButton: .default(
                                Text("OK"),
                                action: {
                                    
                                }
                            )
                        )
                    } else {
                        return emailSentSuccessful
                    }
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

