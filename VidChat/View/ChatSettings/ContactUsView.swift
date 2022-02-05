//
//  ContactUsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct ContactUsView: View {
    
    @State private var message = ""
    @State private var showAlert = false
    @Environment(\.presentationMode) var mode
    
    let viewModel = ContactUsViewModel()
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        let emailSentAlert = Alert(
            title: Text("Thank you for messaging us!"),
            message: Text("We will get back to you soon!"),
            dismissButton: .default(
                Text("OK"),
                action: {
                    mode.wrappedValue.dismiss()
                }
            )
        )
        
        VStack(alignment: .center, spacing: 16) {
            
            HStack {
                
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                }
                
                Spacer()
                
                Text("Contact Us")
                    .foregroundColor(.systemBlack)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    viewModel.sendMessage(message)
                    showAlert = true
                } label: {
                    Text("Send")
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundColor(message.isEmpty ? .lightGray : Color(.systemBlue))
                }
                .disabled(message.isEmpty)
                .alert(isPresented: $showAlert) {
                    emailSentAlert
                }

            }
            .frame(width: SCREEN_WIDTH, height: 44)
            .background(Color.systemWhite)
            
            Text("Ask or tell us anything!")
                .font(.system(size: 22, weight: .semibold))
                .padding(.horizontal)
            
            Text("Tell us about any issues you've encountered, features you'd like to see, concerns you have, or ask us questions!")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.textGray)
                .padding(.horizontal)
            
            ZStack(alignment: .top) {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.backgroundGray)
                    .frame(height: 160)
                    .padding(.horizontal)
                
                ZStack(alignment: .leading) {
                    
                    //Place holder
                    if message.isEmpty {
                        TextEditor(text: .constant("Message..."))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .foregroundColor(.gray)
                            .disabled(true)

                    }
                    
                    TextEditor(text: $message)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                }
               
                
//                MultilineTextField("Message", text: $message, height: 160)
                 
                
            }

            
            Spacer()
        }
        
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}
