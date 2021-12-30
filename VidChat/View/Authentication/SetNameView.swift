//
//  SetNameView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//

import SwiftUI

struct SetNameView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var namesEntered = false
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                //email field
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Join VidChat")
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
                    
                    
                    //first name field
                    
                    CustomTextField(text: $firstName, placeholder: Text("First name"), imageName: "person")
                        .foregroundColor(.white)
                    
                    
                    //last name field
                    
                    CustomTextField(text: $firstName, placeholder: Text("Last name"), imageName: "person")
                        .foregroundColor(.white)
                    
                }.padding(.horizontal, 32)
                
                
                //forgot password
                
                //TODO missed call notifications
                
                //sign in
                
                NavigationLink(destination: SetProfileImageView(), isActive: $namesEntered) { EmptyView() }
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("By clicking Agree & Join you agree to VidChat's")
                            .foregroundColor(.mainGray)
                            .font(.system(size: 12, weight: .regular))
                        
                        HStack(spacing: 5) {
                            
                            NavigationLink(
                                destination: TermsAndConditionsView().navigationBarHidden(true),
                                label: {
                                    Text("Terms of Use")
                                        .foregroundColor(Color(.systemBlue))
                                        .font(.system(size: 12, weight: .regular))
                                })
                            
                            Text("and")
                                .foregroundColor(.mainGray)
                                .font(.system(size: 12, weight: .regular))
                            
                            NavigationLink(
                                destination: PrivacyPolicyView().navigationBarHidden(true),
                                label: {
                                    Text("Privacy Policy")
                                        .foregroundColor(Color(.systemBlue))
                                        .font(.system(size: 12, weight: .regular))
                                })
                        }
                    }
                    Spacer()
                }
                .padding(.leading, 32)
                .padding(.top, 6)
                .padding(.bottom, 20)
                
                Button(action: {
                    
                    if !firstName.isEmpty && !lastName.isEmpty {
                        namesEntered = true
                    }
                    
                }, label: {
                    
                    Text("Agree & Join")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 360, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                        .opacity(firstName.isEmpty || lastName.isEmpty ? 0.5 : 1)
                })
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                
                Spacer()
                //go to sign up
                
            }
            
        }
        .padding(.top, -44)
    }
}

