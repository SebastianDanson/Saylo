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
    let keyBoardType: UIKeyboardType
    let becomeFirstResponder: Bool

    
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
                    
                    CustomUITextField(text: $text, isFirstResponder: becomeFirstResponder, allowsSpaces: allowSpaces, keyboardType: keyBoardType)
                        .frame(height: 35)

//                    TextField("", text: $text)
//                        .foregroundColor(.systemBlack)
//                        .keyboardType(keyBoardType)
//                        .onChange(of: text) {
//
//                            if !allowSpaces {
//                                self.text = $0.replacingOccurrences(of: " ", with: "")
//                            }
//                            // Result: "Helloworld"
//                        }
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.lightGray)
            
        }
    }
}

struct CustomUITextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        let allowsSpaces: Bool
        
        var didBecomeFirstResponder = false
        
        init(text: Binding<String>, allowsSpaces: Bool) {
            _text = text
            self.allowsSpaces = allowsSpaces
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
            
            
            self.text = updatedText.replacingOccurrences(of: " ", with: "")
            textField.text = self.text
            
            return false
        }
    }
    
    @Binding var text: String
    var isFirstResponder: Bool
    let allowsSpaces: Bool
    let keyboardType: UIKeyboardType
    
    func makeUIView(context: UIViewRepresentableContext<CustomUITextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        return textField
    }
    
    func makeCoordinator() -> CustomUITextField.Coordinator {
        return Coordinator(text: $text, allowsSpaces: allowsSpaces)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomUITextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
