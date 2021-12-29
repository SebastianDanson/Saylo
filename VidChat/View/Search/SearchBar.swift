//
//  SearchBar.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    @Binding var isEditing: Bool
    
    var isFirstResponder: Bool
    var placeHolder: String
    
    var body: some View {
        
        HStack {
            
            SearchTextField(text: $text, isFirstResponder: isFirstResponder, placeHolderText: placeHolder)
                .padding(8)
                .padding(.horizontal, 26)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                ).onTapGesture {
                    withAnimation {
                        isEditing = true
                    }
                }
            
            if isEditing {
                Button(action: {
                    withAnimation {
                        isEditing = false
                        text = ""
                        ConversationGridViewModel.shared.showAllUsers()
                        UIApplication.shared.endEditing()
                    }
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.black)
                })
                    .padding(.trailing, 8)
                    .transition(.move(edge: .trailing))
                
            }
        }.frame(height: 36)
    }
}

struct SearchTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        
        var didBecomeFirstResponder = false
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
            ConversationGridViewModel.shared.filterUsers(withText: text)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            let viewModel = ConversationGridViewModel.shared
            
            withAnimation {
                viewModel.showSearchBar = false
                viewModel.showAllUsers()
                NewConversationViewModel.shared.isTypingName = false
            }
            
            text = ""
            
            return true
        }
        
    }
    
    @Binding var text: String
    var isFirstResponder: Bool
    var placeHolderText: String
    
    func makeUIView(context: UIViewRepresentableContext<SearchTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeHolderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.grayText]
        )
        return textField
    }
    
    func makeCoordinator() -> SearchTextField.Coordinator {
        return Coordinator(text: $text)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SearchTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

