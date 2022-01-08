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
    let allowSpaces: Bool
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .leading) {
                
                if text.isEmpty {
                    placeholder.foregroundColor(.systemBlack)
                        .opacity(0.6)
                        .padding(.leading, 30)
                }
                
                HStack {
                    
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                        .foregroundColor(.systemBlack)
                    
                    TextField("", text: $text)
                        .foregroundColor(.systemBlack)
                        .frame(height: 35)
                        .onChange(of: text) {
                            
                            if !allowSpaces {
                                self.text = $0.replacingOccurrences(of: " ", with: "")
                            }
                            // Result: "Helloworld"
                        }
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
            
        }
    }
}
