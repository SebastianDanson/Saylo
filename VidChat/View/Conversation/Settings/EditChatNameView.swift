//
//  EditChatNameView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-16.
//

import SwiftUI

struct EditChatNameView: View {
    
    @State var chatName: String
    @Binding var showEditName: Bool
    
    init(chatName: String, showEditName: Binding<Bool>) {
        self._chatName = State(initialValue: chatName)
        self._showEditName = showEditName
    }
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 12) {
                
                VStack(spacing: 2) {
                    
                    Text("Edit name for")
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                    
                    Text(chatName)
                        .fontWeight(.semibold)
                }
                
                
                ZStack {
                    NameTextField(text: $chatName)
                        .frame(width: SCREEN_WIDTH - 172, height: 44)
                }
                .frame(width: SCREEN_WIDTH - 152, height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(5)
                
                
                
                Button {
                    ChatSettingsViewModel.shared.updateChatName(name: chatName)
                    
                    withAnimation {
                        showEditName = false
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 44)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                    
                }.padding(.top, 4)
                
                
                Button {
                    withAnimation {
                        showEditName = false
                    }
                    
                } label: {
                    
                    Text("Cancel")
                        .foregroundColor(.systemBlack)
                        .font(.system(size: 13))
                }
                .padding(.bottom, 2)
            }
            .padding()
            .frame(width: SCREEN_WIDTH - 120)
            .background(Color.popUpSystemWhite)
            .cornerRadius(16)
            
        }
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .background(Color(white: 0, opacity: 0.3))
        .ignoresSafeArea()
        
    }
}

