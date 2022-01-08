//
//  CustomSecureField.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct CustomSecureField: View {
    @Binding var text: String
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .leading) {
                
                if text.isEmpty {
                    Text("Password").foregroundColor(.systemBlack)
                        .opacity(0.6)
                        .padding(.leading, 30)
                }
                
                HStack {
                    Image(systemName: "lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(.systemBlack)
                    
                    SecureField("", text: $text)
                        .foregroundColor(.systemBlack)
                        .frame(height: 35)
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
        }
    }
}
