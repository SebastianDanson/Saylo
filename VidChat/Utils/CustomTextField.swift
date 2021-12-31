//
//  CustomTextField.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: Text
    let imageName: String
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .leading) {
                
                if text.isEmpty {
                    placeholder.foregroundColor(Color(.init(white: 0, alpha: 0.6)))
                        .padding(.leading, 30)
                }
                
                HStack {
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(.black)
                    
                    TextField("", text: $text)
                        .foregroundColor(.black)
                        .frame(height: 35)
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
            
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(text: .constant(""), placeholder: Text("Email"), imageName: "envelope")
    }
}
