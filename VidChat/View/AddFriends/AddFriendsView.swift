//
//  AddFriendsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct AddFriendsView: View {
    
    @StateObject var viewModel = AddFriendsViewModel.shared
    @State var searchText: String = ""
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        
                        withAnimation {
                            ConversationGridViewModel.shared.showAddFriends = false
                            ConversationGridViewModel.shared.showFindFriends = false
                        }
                        
                        AddFriendsViewModel.shared.reset()
                        
                    } label: {
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.systemBlack)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                }
                .frame(height: 44)
                .background(Color.backgroundGray)
                
                Text("Add Friends")
                    .foregroundColor(.systemBlack)
                    .fontWeight(.semibold)
                
            }
            .frame(width: SCREEN_WIDTH, height: 44)
            .background(Color.backgroundGray)
            .padding(.top, TOP_PADDING)
            
            SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: false, placeHolder: "Find Friends", showSearchReturnKey: true)
                .padding(.horizontal, 20)
                .padding(.bottom)
            
            
            ScrollView() {
                
                
                VStack(alignment: .leading) {
                    
                    if viewModel.searchedUsers.count > 0 {
                        
                        Text("Add Friends")
                            .foregroundColor(.systemBlack)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.leading, 20)
                        
                        
                        VStack(spacing: 0) {
                            
                            ForEach(Array(viewModel.searchedUsers.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user, addedMe: viewModel.friendRequests.contains(where: {$0.id == user.id}), users: $viewModel.searchedUsers)
                                
                            }
                            
                        } .frame(width: SCREEN_WIDTH - 40)
                            .background(Color.popUpSystemWhite)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                        
                    }
                    
                    if viewModel.friendRequests.count > 0 && viewModel.searchedUsers.count == 0 {
                        Text("Added Me")
                            .foregroundColor(.systemBlack)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.leading, 20)
                            .padding(.top, viewModel.searchedUsers.count == 0 ? 0 : 28)

                    }
                    
                    VStack(spacing: 0) {
                        
                        if viewModel.searchedUsers.count == 0 {
                            
                            ForEach(Array(viewModel.friendRequests.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user, addedMe: true, users: $viewModel.friendRequests)
                                
                            }
                        }
                        
                    } .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.popUpSystemWhite)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    
                    if viewModel.contactsOnSaylo.count > 0 && viewModel.searchedUsers.count == 0 {
                        Text("Quick Add")
                            .foregroundColor(.systemBlack)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, viewModel.friendRequests.count == 0 && viewModel.searchedUsers.count == 0 ? 0 : 28)
                            .padding(.leading, 20)
                    }
                    
                    VStack(spacing: 0) {
                        
                        if viewModel.searchedUsers.count == 0 {
                            
                            ForEach(Array(viewModel.contactsOnSaylo.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user,
                                              addedMe: AuthViewModel.shared.currentUser?.friendRequests.contains(user.id) ?? false,
                                              users: $viewModel.contactsOnSaylo)
                                
                            }
                        }
                        
                    }.frame(width: SCREEN_WIDTH - 40)
                        .background(Color.popUpSystemWhite)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    
                    if let contacts = viewModel.contacts {
                        Text("Contacts")
                            .foregroundColor(.systemBlack)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, viewModel.friendRequests.count == 0 && viewModel.contactsOnSaylo.count == 0 && viewModel.searchedUsers.count == 0 ? 0 : 28)
                            .padding(.leading, 20)
                        
                        
                        LazyVStack(spacing: 0) {
                            
                            
                            ForEach(Array(contacts.enumerated()), id: \.1.id) { i, contact in
                                
                                ContactCell(contact: contact, index: i)
                                
                            }
                            
                            
                        }.frame(width: SCREEN_WIDTH - 40)
                            .background(Color.popUpSystemWhite)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    } else  {
                        HStack {
                            Spacer()
                            FindFriendsView()
                                .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
                            Spacer()
                        }
                        
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.backgroundGray)
        //        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .ignoresSafeArea()
        .onAppear {
            AddFriendsViewModel.shared.fetchFriendRequests()
            AddFriendsViewModel.shared.setSeenFriendRequests()
            AddFriendsViewModel.shared.setContacts()
            ContactsViewModel.shared.getContactsWithAccount()
        }
    }
}

