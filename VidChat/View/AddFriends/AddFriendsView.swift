//
//  AddFriendsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct AddFriendsView: View {
    
    @StateObject var viewModel = AddFriendsViewModel.shared
    
    @State var searchText: String = ""
    @State var friendRequests = [User]()
    @State var suggestedUsers = [User]()
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        
                        withAnimation {
                            ConversationGridViewModel.shared.showAddFriends = false
                        }
                        
                    } label: {
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                }
                .frame(height: 44)
                .background(Color.backgroundGray)
                
                Text("Add Friends")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
            }
            .frame(width: SCREEN_WIDTH, height: 44)
            .background(Color.backgroundGray)
            .padding(.top, TOP_PADDING)
            
            SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: false, placeHolder: "Find Friends", showSearchReturnKey: true)
                .padding(.horizontal, 20)
                .padding(.bottom)
            
            
            TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.scrollViewContentOffset) {
                
                
                VStack(alignment: .leading) {
                    
                    if viewModel.searchedUsers.count > 0 {
                        
                        Text("Add Friends")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.leading, 20)
                        
                        
                        VStack(spacing: 0) {
                            
                            ForEach(Array(viewModel.searchedUsers.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user, addedMe: false, isSearch: true, users: $viewModel.searchedUsers)
                                
                            }
                            
                        } .frame(width: SCREEN_WIDTH - 40)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                        
                    }
                    
                    if friendRequests.count > 0 && viewModel.searchedUsers.count == 0 {
                        Text("Added Me")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.leading, 20)
                    }
                    
                    VStack(spacing: 0) {
                        
                        if viewModel.searchedUsers.count == 0 {
                            ForEach(Array(friendRequests.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user, addedMe: true, isSearch: false, users: $friendRequests)
                                
                            }
                        }
                        
                    } .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    
                    if suggestedUsers.count > 0 && viewModel.searchedUsers.count == 0 {
                        Text("Quick Add")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, 28)
                            .padding(.leading, 20)
                    }
                    
                    VStack(spacing: 0) {
                        
                        if viewModel.searchedUsers.count == 0 {
                            
                            ForEach(Array(suggestedUsers.enumerated()), id: \.1.id) { i, user in
                                
                                AddFriendCell(user: user, addedMe: true, isSearch: false, users: $suggestedUsers)
                                
                            }
                        }
                        
                    } .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                }
                
                    FindFiendsView()
            }
            
            Spacer()
        }
        .background(Color.backgroundGray)
        //        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .ignoresSafeArea()
    }
}

