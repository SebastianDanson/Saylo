//
//  NewConversationView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher
import Combine

struct NewConversationView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    @StateObject var gridViewModel = ConversationGridViewModel.shared

    @State var searchText: String = ""
    @State var chatName: String = ""
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        
        ZStack {
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
                                    gridViewModel.showNewChat = false
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
                
                SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: false, placeHolder: "Search", showSearchReturnKey: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                
                
                ScrollView() {
                    
                    VStack(alignment: .leading) {
                        
                        CreateNewGroupView(chatName: $chatName)
                        
                        if viewModel.addedChats.count > 0 {
                            
                            AddedChatsView()
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
                            
                            ForEach(gridViewModel.chats, id: \.id) { chat in
                                
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
            .background(Color.backgroundGray)
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
                        gridViewModel.showNewChat = false
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
    }
    
    func isButtonEnabled() -> Bool {
        return viewModel.isCreatingNewChat || viewModel.addedChats.count > 0
    }
}

struct NewConversationCell: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    let chat: Chat
    
    var body: some View {
        
        Button {
            viewModel.handleChatSelected(chat: chat)
        } label: {
            
            HStack(spacing: 12) {
                
                ChatImage(chat: chat, diameter: 40)
                    .padding(.leading, 12)
                
                
                Text(chat.fullName)
                    .lineLimit(2)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.systemBlack)
                
                Spacer()
                
                Circle()
                    .stroke(viewModel.containsChat(chat) ? Color.systemWhite : Color.lighterGray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    .frame(width: 28, height: 28)
                    .overlay(
                        ZStack {
                            if viewModel.containsChat(chat) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.mainBlue)
                            }
                        }
                    )
                    .padding(.horizontal)
                
            }.frame(height: 52)
        }

    }
}


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

struct AddedChatsView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    var body: some View {
        
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.addedChats.enumerated()), id: \.1.id) { i, chat in
                            AddedUserView(chat: chat)
                                .padding(.leading, i == 0 ? 20 : 5)
                                .padding(.trailing, i == viewModel.addedChats.count - 1 ? 80 : 5)
                                .transition(.scale)
                            
                        }
                        
                    }.padding(.vertical)
                }.frame(width: SCREEN_WIDTH - 40, height:  60)
            }
        }
        .transition(.identity)
    }
}

struct AddedUserView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    let chat: Chat
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center, spacing: 4) {
                
                ChatImage(chat: chat, diameter: 44)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(chat.name)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 136/255, green: 137/255, blue: 141/255))
                    .frame(maxWidth: 50)
            }
            
            Button {
                withAnimation {
                    viewModel.addedChats.removeAll(where: { $0.id == chat.id})
                }
            } label: {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.toolBarIconGray)
                        .frame(width: 20, height: 20)
                    
                    Image("x")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(white: 0.4, opacity: 1))
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    
                }
                .padding(.top, 4)
                .padding(.trailing, -6)
            }
        }
    }
}

//TODO if u try and create a group and there's already a group that contains all of the same users then don't create a new group just go to that group chat.
//See snapchat for what is expected

