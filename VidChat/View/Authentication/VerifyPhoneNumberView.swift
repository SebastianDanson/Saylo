//
//  VerifyPhoneNumberView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-22.
//

import SwiftUI

struct VerifyPhoneNumberView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var verificationCode = ""
    @State private var showInvalidCode = false
    @State private var showError = false
    @State private var countryCode = ""
    @State private var showCountryList = false
    @State private var countryInitials = ""
    
    let phoneNumber: String
    let dialCode: String
    
    var body: some View {
        
        let invalidCodeAlert = Alert(
            title: Text("Invalid Code"),
            message: Text("Please enter the code that was sent"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        
        VStack {
            
            //email field
            
            VStack(spacing: 24) {
                
                VStack(alignment: .center, spacing: 4) {
                    
                    Text("Enter Confirmation Code")
                        .font(.system(size: 24, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.top, TOP_PADDING + 8)
                    
                    
                    Text("Enter the code we sent to \(dialCode)\n\(phoneNumber)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.mainGray)
                        .multilineTextAlignment(.center)
                    
                    
                    Button {
                        
                    } label: {
                        Text("Resend Code")
                            .foregroundColor(.mainBlue)
                            .font(.system(size: 11))
                    }

                }.padding(.bottom, 16)
                
                
                //Username field
                
                VStack(spacing: -2) {
                    
                    HStack {
                        
                        Button {
                            showCountryList = true
                        } label: {
                            Text(countryInitials + " +" + countryCode)
                                .foregroundColor(.mainBlue)
                        }
                        
                        
                        Rectangle()
                            .frame(width: 1, height: 22)
                            .foregroundColor(.lightGray)
                            .padding(.bottom, 2)
                        
                        SectionedTextField()
//                        TextField("Phone number", text: $phoneNumber)
//                            .foregroundColor(.systemBlack)
//                            .frame(height: 35)
//                            .keyboardType(.numberPad)
                        
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.lightGray), alignment: .bottom)
                    .padding(.top, 2)
                    .padding(.bottom)
                    .padding(.horizontal)
                    
                    
                    
                    //            NavigationLink(destination: SetProfileImageView(), isActive: $nameEntered) { EmptyView() }
                    
                    HStack {
                        Text("We'll send you an SMS verification code.")
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(.leading, 14)
                    
                }.padding(.horizontal, 32)
                
                
            }
            Button(action: {
                
              
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6 ? 0.5 : 1)
            })
                .disabled(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6)
                .padding(.vertical, 28)
                .alert(isPresented: $showInvalidCode) {
                    invalidCodeAlert
                }
            
            
            Spacer()
            
        }
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Text("Skip")
                        .foregroundColor(Color(.systemGray3))
                        .fontWeight(.medium)
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
}
