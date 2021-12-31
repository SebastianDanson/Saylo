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
    @State private var showInvalidName = false

    
    var body: some View {
        
        let invalidNameAlert = Alert(
            title: Text("Your name must be under 50 characters"),
            message: nil,
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        ZStack {
            
            VStack {
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    HStack() {
                        
                        Spacer()
                        
                        Text("What's your name?")
                            .font(.system(size: 30, weight: .medium))
                        
                        Spacer()
                        
                    }.padding(.bottom, 6)
                    
                    
                    //first name field
                    
                    CustomTextField(text: $firstName, placeholder: Text("First name"), imageName: "person")
                        .foregroundColor(.white)
                    
                    
                    //last name field
                    
                    CustomTextField(text: $lastName, placeholder: Text("Last name"), imageName: "person")
                        .foregroundColor(.white)
                    
                    
                }.padding(.horizontal, 32)
                
                                
                //TODO missed call notifications
                
                //sign in
                
                NavigationLink(destination: SetUsernameView(), isActive: $namesEntered) { EmptyView() }
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("By clicking Agree & Join you agree to VidChat's")
                            .foregroundColor(.mainGray)
                            .font(.system(size: 12, weight: .regular))
                        
                        HStack(spacing: 5) {
                            
                            NavigationLink(
                                destination: TermsAndConditionsView()
                                    .navigationTitle("Terms of Use")
                                    .navigationBarBackButtonHidden(false)
                                    .navigationBarTitleDisplayMode(.automatic),
                                label: {
                                    Text("Terms of Use")
                                        .foregroundColor(Color(.systemBlue))
                                        .font(.system(size: 12, weight: .regular))
                                })
                            
                            Text("and")
                                .foregroundColor(.mainGray)
                                .font(.system(size: 12, weight: .regular))
                            
                            NavigationLink(
                                
                                destination: PrivacyPolicyView()
                                    .navigationTitle("Terms of Use")
                                    .navigationBarBackButtonHidden(false)
                                    .navigationBarTitleDisplayMode(.automatic),
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
                    
                    if firstName.trimmingCharacters(in: [" "]).count + lastName.trimmingCharacters(in: [" "]).count >= 50 {
                        showInvalidName = true
                    } else {
                        viewModel.setName(firstName: firstName, lastName: lastName)
                        namesEntered = true
                    }
                    
                }, label: {
                    
                    Text("Agree & Join")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: SCREEN_WIDTH - 64, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                        .opacity(hasValidName() ? 1 : 0.5)
                })
                    .disabled(!hasValidName())
                    .alert(isPresented: $showInvalidName) {
                        invalidNameAlert
                    }
                
                Spacer()
                
            }
        }
    }
    
    func hasValidName() -> Bool {
        return !firstName.trimmingCharacters(in: [" "]).isEmpty && !lastName.trimmingCharacters(in: [" "]).isEmpty
    }
}

