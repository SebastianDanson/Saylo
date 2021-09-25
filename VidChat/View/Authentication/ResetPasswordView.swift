//
//  ResetPasswordView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding private var email: String
    @Environment(\.presentationMode) var mode
    
    init(email: Binding<String>) {
        self._email = email
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack {
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 100)
                
                //email field
                
                VStack(spacing: 20) {
                    CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope")
                        .padding()
                        .background(Color(.init(white: 1, alpha: 0.15)))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                    
                    //password field
                    
                }
                
                
                //forgot password
                
                HStack {
                    Spacer()
                    Button(action: {}, label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top)
                            .padding(.trailing, 28)
                    })
                }
                
                //sign in
                
                Button(action: { viewModel.resetPassword(withEmail: email) }, label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 50)
                        .background(Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)))
                        .clipShape(Capsule())
                }).padding()
                
                //go to sign up
                
                Spacer()
                
                Button(action: {mode.wrappedValue.dismiss()}, label: {
                    HStack {
                        Text("Already have an account?").font(.system(size: 14))
                        
                        Text("Sign In")
                            .font(.system(size: 14, weight: .semibold))
                    }.foregroundColor(.white)
                })
            } .padding(.top, -44)
        }.onReceive(viewModel.$didSendResetPasswordLink, perform: { _ in
            self.mode.wrappedValue.dismiss()
        })
      
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(email: .constant(""))
    }
}
