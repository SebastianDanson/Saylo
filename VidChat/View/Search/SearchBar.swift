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
    var showSearchReturnKey: Bool
    
    var body: some View {
        
        HStack {
            
            SearchTextField(text: $text, isEditing: $isEditing, isFirstResponder: isFirstResponder, placeHolderText: placeHolder, showSearchReturnKey: showSearchReturnKey)
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
                        ConversationGridViewModel.shared.showAllChats()
                        ChatSettingsViewModel.shared.showAllChats()
                        UIApplication.shared.endEditing()
                        
                      
                    }
                }, label: {
                    Text("Cancel")
                        .foregroundColor(.systemBlack)
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
        @Binding var isEditing: Bool

        var didBecomeFirstResponder = false
        var showSearchReturnKey: Bool
        var searchText = ""
        var lastPerformArgument: NSString? = nil
        
        init(text: Binding<String>, isEditing: Binding<Bool>, showSearchReturnKey: Bool) {
            _text = text
            _isEditing = isEditing
            self.showSearchReturnKey = showSearchReturnKey
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            ConversationGridViewModel.shared.filterUsers(withText: text)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            
            let viewModel = ConversationGridViewModel.shared
            
            withAnimation {
                viewModel.showSearchBar = false
                viewModel.showAllChats()
                NewConversationViewModel.shared.isTypingName = false
            }
            
            text = ""
            
            isEditing = false
            text = ""
            ConversationGridViewModel.shared.showAllChats()
            UIApplication.shared.endEditing()
            
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            if showSearchReturnKey {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: lastPerformArgument)
                lastPerformArgument = text as NSString

                if let text = textField.text,
                   let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange,
                                                               with: string)
                    self.searchText = updatedText
                    AddFriendsViewModel.shared.filterUsers(withText: updatedText)
                }
                
                AddFriendsViewModel.shared.showSearchResults = self.searchText.count > 1
                
                if self.searchText.count > 1 {
                    perform(#selector(reload), with: lastPerformArgument, afterDelay: 0.6)
                } else {
                    withAnimation {
                        AddFriendsViewModel.shared.searchedUsers.removeAll()
                    }
                }
                
            } else {
                
                if let text = textField.text,
                   let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange,
                                                               with: string)
                    self.text = updatedText
                    
                    ChatSettingsViewModel.shared.filterUsers(withText: updatedText)
                    ConversationGridViewModel.shared.filterUsers(withText: updatedText)

                } else {
                    ConversationGridViewModel.shared.showAllChats()
                    ChatSettingsViewModel.shared.showAllChats()
                }
         
            }
            
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            
            textField.text = ""
            
            if showSearchReturnKey {
                AddFriendsViewModel.shared.searchedUsers.removeAll()
            }
        }
        
        @objc func reload() {
            AddFriendsViewModel.shared.search(withText: searchText)
        }
        
    }
    
    @Binding var text: String
    @Binding var isEditing: Bool

    var isFirstResponder: Bool
    var placeHolderText: String
    var showSearchReturnKey: Bool
    var textField = UITextField(frame: .zero)
    
    func makeUIView(context: UIViewRepresentableContext<SearchTextField>) -> UITextField {
        textField.delegate = context.coordinator
        
        textField.returnKeyType = showSearchReturnKey ? .search : .default
        textField.text = text
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeHolderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textGray]
        )
        return textField
    }
    
    func makeCoordinator() -> SearchTextField.Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing, showSearchReturnKey: showSearchReturnKey)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SearchTextField>) {
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

