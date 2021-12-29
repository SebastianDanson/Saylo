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
            
            SearchBar(text: $searchText, isEditing: $viewModel.isSearching, isFirstResponder: false, placeHolder: "Find Friends")
                .padding(.horizontal, 20)
                .padding(.bottom)
            
            
            TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.scrollViewContentOffset) {
                
                
                VStack(alignment: .leading) {
                    
                    Text("Added Me")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.leading, 20)
                    
                    VStack(spacing: 0) {
                        
                        AddFriendCell(user: ConversationGridViewModel.shared.users[0], addedMe: true)
                        AddFriendCell(user: ConversationGridViewModel.shared.users[1], addedMe: true)
                        
                    } .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                    
                    Text("Quick Add")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 28)
                        .padding(.leading, 20)
                    
                    VStack(spacing: 0) {
                        
                        AddFriendCell(user: ConversationGridViewModel.shared.users[0], addedMe: false)
                        AddFriendCell(user: ConversationGridViewModel.shared.users[1], addedMe: false)
                        AddFriendCell(user: ConversationGridViewModel.shared.users[2], addedMe: false)
                        
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
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//        .ignoresSafeArea()
    }
}

