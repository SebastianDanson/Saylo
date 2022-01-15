//
//  CreateNewGroupView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI

struct CreateNewGroupView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    @Binding var chatName: String
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundColor(showCreateChat() ? .systemWhite : .mainBlue)
                
                Image(systemName: showCreateChat() ? "pencil" : "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(showCreateChat() ? .systemBlack : .systemWhite)
                    .frame(width: showCreateChat() ? 20 : 24, height: showCreateChat() ? 20 : 24)
                
            }.padding(.leading, 12)
            
            if showCreateChat() {
                
                HStack {
                    
                    TextField("Group Name", text: $chatName)
                        .onTapGesture {
                            viewModel.isTypingName = true
                        }
                    Spacer()
                    
                }
                
            } else {
                
                Text("Create a new group")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.systemBlack)
            }
            
            Spacer()
            
        }
        .frame(width: SCREEN_WIDTH - 40, height: 50)
        .background(Color.popUpSystemWhite)
        .cornerRadius(10)
        .onTapGesture(perform: {
            
            if !viewModel.isCreatingNewChat {
                
                withAnimation {
                    viewModel.isCreatingNewChat = true
                }
            }
        })
        .padding(.horizontal, 20)
        .shadow(color: Color(.init(white: 0, alpha: 0.07)), radius: 16, x: 0, y: 2)
    }
    
    func showCreateChat() -> Bool {
        viewModel.isCreatingNewChat || viewModel.addedChats.count > 1
    }
}


