//
//  NewConversationView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher
import Combine

struct NewConversationView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared

    @State var searchText: String = ""
    @State var chatName: String = ""
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        
        ZStack {
            
            Color.backgroundGray.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                ZStack {
                    
                    HStack {
                        
                        Button {
                            
                            if viewModel.isCreatingNewChat {
                                
                                withAnimation {
                                    viewModel.isCreatingNewChat = false
                                    viewModel.isTypingName = false
                                }
                                
                            } else {
                                
                                withAnimation {
                                    ConversationGridViewModel.shared.showNewChat = false
                                }
                                
                                viewModel.addedChats.removeAll()
                                viewModel.isCreatingNewChat = false
                                searchText = ""
                            }
                            
                        } label: {
                            
                            if viewModel.isCreatingNewChat {
                                
                                Text("Cancel")
                                    .foregroundColor(Color(.systemBlue))
                                    .padding()
                                
                            } else {
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.systemBlack)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    
                 
                        Text("New Chat")
                            .foregroundColor(.systemBlack)
                            .fontWeight(.semibold)
                    
                }
                .frame(height: 44)
                .background(Color.backgroundGray)
                .padding(.top, TOP_PADDING)
                
                VStack{
                    Spacer()
                SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: false, placeHolder: "Search", showSearchReturnKey: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                    Spacer()
                }
                .frame(height: 48)
                
                
                ScrollView() {
                    
                    VStack(alignment: .leading) {
                        
                        CreateNewGroupView(chatName: $chatName)
                        
                        if viewModel.addedChats.count > 0 {
                            
                            AddedChatsView(chats: $viewModel.addedChats)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                        }
                        
                        Text("SUGGESTED")
                            .foregroundColor(.textGray)
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.leading, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 2)
                            .opacity(0.85)
                        
                        VStack(spacing: 0) {
                            
                            ForEach(viewModel.chats, id: \.id) { chat in
                                
                                NewConversationCell(chat: chat)
                                
                            }
                            
                        }.frame(width: SCREEN_WIDTH - 40)
                            .background(Color.popUpSystemWhite)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    }
                    
                }
                
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                Button {
                                        
                    if viewModel.isCreatingNewChat {
                        viewModel.createChat(name: chatName)
                    } else if let chat = viewModel.getSelectedChat() {
                        ConversationViewModel.shared.setChat(chat: chat)
                        ConversationGridViewModel.shared.showConversation = true
                    } else {
                        viewModel.createChat(name: chatName)
                    }
                    
                    viewModel.isCreatingNewChat = false
                    viewModel.addedChats.removeAll()
                    
                    chatName = ""
                    
                    withAnimation {
                        MainViewModel.shared.showNewChat = false
                    }
                    
                } label: {
                    
                    Text(viewModel.isCreatingNewChat ? "Create Group" : (viewModel.addedChats.count > 1) ? "Chat with Group" : "Chat")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.systemWhite)
                        .frame(width: 180, height: 52)
                        .background(Color.mainBlue)
                        .opacity(isButtonEnabled() ? 1 : 0.3)
                        .clipShape(Capsule())
                        .disabled(!isButtonEnabled())
                }
                .padding(.bottom, viewModel.isTypingName || viewModel.isSearching ? keyboardHeight + 20 : BOTTOM_PADDING + 16)
            }
        }.onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
        .onAppear {
            NewConversationViewModel.shared.setChats()
        }
    }
    
    func isButtonEnabled() -> Bool {
        return viewModel.isCreatingNewChat || viewModel.addedChats.count > 0
    }
}




