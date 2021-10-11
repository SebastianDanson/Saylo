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
        VStack(spacing: 16) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Password").foregroundColor(Color(.init(white: 0, alpha: 0.8)))
                        .padding(.leading, 30)
                }
                
                HStack {
                    Image(systemName: "lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                    
                    SecureField("", text: $text)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
        }
    }
}
