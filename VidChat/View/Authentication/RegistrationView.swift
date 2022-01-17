//
//  RegistrationView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var isLoading = false

    @State private var canProceed = false
    @State private var error: Error?
    
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
        
        VStack {
            //email field
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("Sign up")
                        .font(.system(size: 30, weight: .medium))
                    
                    NavigationLink(
                        destination: LoginView(),
                        label: {
                            Text("or ").foregroundColor(.systemBlack) +
                            
                            Text("Login")
                                .foregroundColor(.mainBlue)
                                .fontWeight(.medium)
                        })
                    
                    
                }.padding(.bottom, 6)
                
                
                //email field
                CustomTextField(text: $email, placeholder: Text("Email"), imageName: "envelope", allowSpaces: true)
                    .foregroundColor(.systemWhite)
                
                
                if showPassword {
                    
                    //password field
                    CustomSecureField(text: $password)
                        .foregroundColor(.systemWhite)
                }
                
                
            }.padding(.horizontal, 32)
            
            
            //forgot password
            
            HStack {
                Spacer()
                NavigationLink(
                    destination: ResetPasswordView(),
                    label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.systemWhite)
                            .padding(.top)
                            .padding(.trailing, 28)
                    })
            }
            
            //sign in
            
            NavigationLink(destination: SetNameView()
                            .navigationBarBackButtonHidden(true), isActive: $canProceed) { EmptyView() }
            
            Button(action: {
                
                if !showPassword {
                    if isValidEmail(email.replacingOccurrences(of: " ", with: "")) {
                        withAnimation {
                            showPassword = true
                        }
                    } else {
                        showError = true
                    }
                } else {
                    
                    isLoading = true
                    
                    viewModel.register(withEmail: email.replacingOccurrences(of: " ", with: ""), password: password) { error in
                        
                        isLoading = false
                        
                        if let error = error {
                            self.error = error
                            showError = true
                        } else {
                          
                            canProceed = true
                        }
                    }
                }
                
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 64, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(email.isEmpty || (password.isEmpty && showPassword) ? 0.5 : 1)
            })
                .disabled(email.isEmpty || isLoading || (password.isEmpty && showPassword))
                .alert(isPresented: $showError) {
                    
                    if let error = error {
                        return Alert(
                            title: Text("Error"),
                            message: Text("\(error.localizedDescription)"),
                            dismissButton: .default(
                                Text("OK"),
                                action: {
                                    self.error = nil
                                }
                            )
                        )
                    } else {
                        return invalidEmailAlert
                    }
                }
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
                
            }
            
            Spacer()
            
        }

    }
    
    func isValidEmail(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
