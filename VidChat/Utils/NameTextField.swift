//
//  NameTextField.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-16.
//

import SwiftUI

struct NameTextField: UIViewRepresentable {
    
    @Binding var text: String
    
    var textField = UITextField(frame: .zero)
    
    func makeUIView(context: UIViewRepresentableContext<NameTextField>) -> UITextField {
        textField.text = text
        textField.layer.cornerRadius = 5
        textField.delegate = context.coordinator
        return textField
    }
    
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<NameTextField>) {
        uiView.becomeFirstResponder()
    }
    
    func makeCoordinator() -> NameTextField.Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                
                self.text = updatedText
            } else {
                self.text = ""
            }
            
            print(self.text, "TEXT")
            return true
        }
    }
}

