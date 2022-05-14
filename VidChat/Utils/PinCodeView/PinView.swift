//
//  PinView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-28.
//

import SwiftUI

struct PinView: UIViewRepresentable {
    
    @Binding var text: String
    
    @Environment(\.presentationMode) var mode
    
    func makeUIView(context: Context) -> some UIView {
        let pinView = VKPinCodeView()
        pinView.onSettingStyle = {
            UnderlineStyle(textColor: .systemBlack, lineColor: .lightGray, selectedLineColor: .mainBlue, lineWidth: 2)
        }
        pinView.delegate = context.coordinator
        pinView.validator = validator(_:)
        return pinView
    }
    
    
    private func validator(_ code: String) -> Bool {
        
        return !code.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).isEmpty
    }
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.becomeFirstResponder()
    }
    
    func makeCoordinator() -> PinView.Coordinator {
        return Coordinator(self)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.text = textField.text ?? ""
        }
    }
    
    
    
    class Coordinator: NSObject, VKPinCodeViewDelegate  {
       
        func textDidChange(text: String) {
            self.parent.text = text
        }

        let parent: PinView

        init(_ parent: PinView) {
            self.parent = parent
        }

       
    }
}
