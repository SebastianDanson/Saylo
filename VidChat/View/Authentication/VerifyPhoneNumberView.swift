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
    @State private var showNewCodeSent = false
    @State private var error: Error?
    @State private var showError = false
    @State private var isLoading = false
    @State private var canProceed = false

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
        
        let newCodeSent = Alert(
            title: Text("New verification code sent"),
            message: Text("A new code will be sent shortly to \(dialCode) \(phoneNumber)"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    
                }
            )
        )
        
        let firebaseAlert = Alert(
            title: Text("Invalid Code"),
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
                
                VStack(alignment: .center, spacing: 12) {
                    
                    Text("Enter Confirmation Code")
                        .font(.system(size: 24, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.top, TOP_PADDING + 8)
                    
                    
                    Text("Enter the code we sent to \(dialCode)\n\(phoneNumber)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.mainGray)
                        .multilineTextAlignment(.center)
                    
                    
                    Button {
                        self.isLoading = true
                        viewModel.sendPhoneVerificationCode(phoneNumber: phoneNumber, countryCode: dialCode) { error in
                            self.isLoading = false
                            if let error = error {
                                self.error = error
                                self.showError = true
                            } else {
                                showNewCodeSent = true
                            }
                        }
                    } label: {
                        
                        Text("Resend Code")
                            .foregroundColor(.mainBlue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                }.padding(.bottom, 16)
                
                
                NavigationLink(destination: EnableContactsView(), isActive: $canProceed) { EmptyView() }
                
                SectionedTextField(text: $verificationCode)
                
                Button(action: {
                    
                    isLoading = true
                    viewModel.verifyPhone(verificationCode: verificationCode) { error in
                        self.isLoading = false
                        if error != nil {
                            self.showInvalidCode = true
                            self.showError = true
                        } else {
                            canProceed = true
                        }
                    }
                    
                }, label: {
                    
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: SCREEN_WIDTH - 92, height: 50)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                        .opacity(verificationCode.count != 6 ? 0.5 : 1)
                    
                })
                    .disabled(verificationCode.count != 6 || isLoading)
                    .padding(.vertical, 28)
                    .alert(isPresented: $showError) {
                        
                        if showInvalidCode {
                           return invalidCodeAlert
                        } else if showNewCodeSent {
                           return newCodeSent
                        } else {
                           return firebaseAlert
                        }
                    }
                
                if isLoading {
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 50, height: 50)
                        .padding(.top, -20)
                    
                }
                
                Spacer()
                
            }
            .navigationBarBackButtonHidden(false)
            
        }
        
    }
}

struct SectionedTextField: View {
   
    @Binding var text: String
    
    let width: CGFloat = 36
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            PinCodeTextField(text: $text)
                .padding(.leading, 16)
                .frame(width: 266)
            
            HStack {
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
                Rectangle()
                    .frame(width: width, height: 1)
                    .foregroundColor(.lightGray)
                
            }.frame(width: 246)
            
        }.frame(height: 40)
    }
}


struct PinCodeTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        
        var didBecomeFirstResponder = false
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            let noSpaceText = updatedText.replacingOccurrences(of: " ", with: "")
            
            if updatedText.count < self.text.count {
                self.text.removeLast(min(2, self.text.count))
                self.text.append(" ")
                textField.text = text
            } else if noSpaceText.count <= 6 {
                
                self.text = noSpaceText
                
                if noSpaceText.count < 6 {
                    self.text.append(" ")
                }
                
                textField.text = text
            }
            
            
            return false
        }
    }
    
    @Binding var text: String
    var isFirstResponder: Bool = true
    
    func makeUIView(context: UIViewRepresentableContext<PinCodeTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.textAlignment = .left
        textField.keyboardType = .numberPad
        textField.defaultTextAttributes.updateValue(32.0, forKey: NSAttributedString.Key.kern)
        textField.font = UIFont.systemFont(ofSize: 20)
        return textField
    }
    
    func makeCoordinator() -> PinCodeTextField.Coordinator {
        return Coordinator(text: $text)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<PinCodeTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}




