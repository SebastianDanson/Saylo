//
//  SetPhoneNumberView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI
import CoreTelephony

struct CountryInfo {
    let dialCode: String
    let countryCode: String
}

struct SetPhoneNumberView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    
    @State private var phoneNumber = ""
    @State private var showInvalidPhoneNumber = false
    @State private var showError = false
    @State private var countryCode = ""
    @State private var showCountryList = false
    @State private var countryInitials = ""
    @State private var showVerifyPhoneNumber = false
    @State private var isLoading = false
    @State private var canProceed = false

    @State private var error: Error?

    var body: some View {
        
        let invalidPhoneNumberAlert = Alert(
            title: Text("Invalid mobile number"),
            message: Text("Please add a valid mobile number"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        let firebaseAlert = Alert(
            title: Text("Error"),
            message: Text(error?.localizedDescription ?? ""),
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
                    
                    Text("What's your mobile \nnumber?")
                        .font(.system(size: 24, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.top, TOP_PADDING + 8)
                    
                    
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
                        
                        CustomUITextField(text: $phoneNumber, isFirstResponder: true, allowsSpaces: false, keyboardType: .numberPad)
                            .frame(height: 35)
                        
                    }
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.lightGray), alignment: .bottom)
                    .padding(.top, 2)
                    .padding(.bottom)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: EnableContactsView(), isActive: $canProceed) { EmptyView() }

                    
                    NavigationLink(destination: VerifyPhoneNumberView(phoneNumber: phoneNumber.trimmingCharacters(in: .decimalDigits.inverted),
                                                                      dialCode: countryCode),
                                   isActive: $showVerifyPhoneNumber) { EmptyView() }
                    
                    HStack {
                        Text("We'll send you an SMS verification code.")
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .padding(.leading, 14)
                    
                }.padding(.horizontal, 32)
                
                
            }
            
            Button(action: {
                
                
                //set phone number
                if (countryCode == "1" && phoneNumber.trimmingCharacters(in: .decimalDigits.inverted).count == 10) || (countryCode != "1" && ("+" + countryCode + phoneNumber).isValidPhoneNumber()) {
                    
                    isLoading = true
                    viewModel.setPhoneNumber(phoneNumber: phoneNumber.trimmingCharacters(in: .decimalDigits.inverted), countryCode: countryCode) { error in
                       
                        self.isLoading = false

                        if error != nil {
                            self.showInvalidPhoneNumber = true
                            self.showError = true
                        } else {
                            showVerifyPhoneNumber = true
                        }
                        
                    }
                } else {
                    showInvalidPhoneNumber = true
                    showError = true
                }
                
            }, label: {
                
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .opacity(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6 ? 0.5 : 1)
            })
                .disabled(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count < 6 || isLoading)
                .padding(.vertical, 28)
                .alert(isPresented: $showError) {
                    
                    if showInvalidPhoneNumber {
                      return invalidPhoneNumberAlert
                    } else {
                       return firebaseAlert
                    }
                }
            
            
            if isLoading {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
                    .padding(.top, -8)

            }
            
            Spacer()
            
            
        }
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    canProceed = true
                } label: {
                    Text("Skip")
                        .foregroundColor(Color(.systemGray3))
                        .fontWeight(.medium)
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCountryList, content: {
            NavigationView {
                CountryCodeViewController(countryInitials: $countryInitials, dialCode: $countryCode)
                    .navigationTitle("Country Codes")
            }
        })
        .onAppear {
            let countryInfo = getCountryCode()
            self.countryCode = countryInfo.dialCode
            self.countryInitials = countryInfo.countryCode
            
        }
        
    }
    
    func getCountryCode() -> CountryInfo {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode else { return CountryInfo(dialCode: "1", countryCode: "") }
       
        let prefixCodes = ContactsViewModel.shared.getCountryPrefixCodes()
        let countryDialingCode = prefixCodes[countryCode.uppercased()] ?? String("1")
        return CountryInfo(dialCode: countryDialingCode, countryCode: countryCode.uppercased())
    }
}


struct Config {
    init() {}
    static var localIdentifier: Locale!
}



