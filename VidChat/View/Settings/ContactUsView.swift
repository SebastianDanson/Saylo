//
//  ContactUsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct ContactUsView: View {
    
    @State private var message = ""
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .padding()
                }
                
                Spacer()
                
                Text("Contact Us")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    //TODO handle Send
                } label: {
                    Text("Send").fontWeight(.semibold)
                        .padding()
                }

            }
            .background(Color.white)
            .frame(width: SCREEN_WIDTH, height: 44)
            
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
                
                MultilineTextField("Message", text: $message, height: 160)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                
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
