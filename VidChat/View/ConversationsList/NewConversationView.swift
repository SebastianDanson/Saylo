//
//  NewConversationView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher

struct NewConversationView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    @State var searchText: String = ""
    @State var users = [User]()
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                
                ZStack {
                    
                    HStack {
                        
                        Button {
                            
                            if viewModel.isCreatingNewGroup {
                                withAnimation {
                                    viewModel.isCreatingNewGroup = false
                                    viewModel.isTypingName = false
                                }
                            } else {
                                withAnimation {
                                    ConversationGridViewModel.shared.showNewChat = false
                                }
                            }
                            
                        } label: {
                            
                            if viewModel.isCreatingNewGroup {
                                
                                Text("Cancel")
                                    .foregroundColor(Color(.systemBlue))
                                    .padding()
                                
                            } else {
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    
                    Text("New Chat")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    
                }
                .frame(height: 44)
                .background(Color.backgroundGray)
                .padding(.top, TOP_PADDING)
                
                SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: true, placeHolder: "Search", showSearchReturnKey: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                
                
                ScrollView() {
                    
                    VStack(alignment: .leading) {
                        
                        CreateNewGroupView()
                        
                        if viewModel.addedUsers.count > 0 {
                            
                            AddedUsersView()
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
                            
                            ForEach(Array(users.enumerated()), id: \.1.id) { i, user in
                                
                                NewConversationCell(user: user)
                                
                            }
                            
                        }.frame(width: SCREEN_WIDTH - 40)
                            .background(Color.white)
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
                    
                } label: {
                    
                    Text(viewModel.isCreatingNewGroup ? "Create Group" : (viewModel.addedUsers.count > 1) ? "Chat with Group" : "Chat")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 180, height: 52)
                        .background(Color.mainBlue)
                        .clipShape(Capsule())
                }
                .padding(.bottom, viewModel.isTypingName || viewModel.isSearching ? 12 : BOTTOM_PADDING + 16)
            }
        }
    }
}

struct NewConversationCell: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    let user: User
    
    var body: some View {
        
        Button {
            viewModel.handleUserSelected(user: user)
        } label: {
            
            HStack(spacing: 12) {
                
                KFImage(URL(string: user.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading, 12)
                
                
                Text(user.firstName + " " + user.lastName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Circle()
                    .stroke(viewModel.containsUser(user: user) ? Color.white : Color.lighterGray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                    .frame(width: 28, height: 28)
                    .overlay(
                        ZStack {
                            if viewModel.containsUser(user: user) {
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
    
    @State var groupName: String = ""
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundColor(showCreateGroup() ? .white : .mainBlue)
                
                Image(systemName: showCreateGroup() ? "pencil" : "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(showCreateGroup() ? .black : .white)
                    .frame(width: showCreateGroup() ? 20 : 24, height: showCreateGroup() ? 20 : 24)
                
            }.padding(.leading, 12)
            
            if showCreateGroup() {
                
                HStack {
                    
                    TextField("Group Name", text: $groupName)
                        .onTapGesture {
                            viewModel.isTypingName = true
                        }
                    Spacer()
                    
                }
                
            } else {
                
                Text("Create a new group")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
        }
        .frame(width: SCREEN_WIDTH - 40, height: 50)
        .background(Color.white)
        .cornerRadius(10)
        .onTapGesture(perform: {
            
            if !viewModel.isCreatingNewGroup {
                
                withAnimation {
                    viewModel.isCreatingNewGroup = true
                }
            }
        })
        .padding(.horizontal, 20)
        .shadow(color: Color(.init(white: 0, alpha: 0.07)), radius: 16, x: 0, y: 2)
    }
    
    func showCreateGroup() -> Bool {
        viewModel.isCreatingNewGroup || viewModel.addedUsers.count > 1
    }
}

struct AddedUsersView: View {
    
    @StateObject var viewModel = NewConversationViewModel.shared
    
    var body: some View {
        
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.addedUsers.enumerated()), id: \.1.id) { i, user in
                            AddedUserView(user: user)
                                .padding(.leading, i == 0 ? 20 : 5)
                                .padding(.trailing, i == viewModel.addedUsers.count - 1 ? 80 : 5)
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
    
    let user: User
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(alignment: .center, spacing: 4) {
                
                KFImage(URL(string: user.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .background(Color(.systemGray))
                    .frame(width: 44, height: 44)
                    .cornerRadius(44/2)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(user.firstName)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 136/255, green: 137/255, blue: 141/255))
                    .frame(maxWidth: 50)
            }
            
            Button {
                withAnimation {
                    viewModel.addedUsers.removeAll(where: { $0.id == user.id})
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

