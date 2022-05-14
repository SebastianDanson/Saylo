//
//  AllFriendsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-24.
//

import SwiftUI

struct AllFriendsView: View {
    
    @State var chats = [Chat]()
    @StateObject var viewModel = AddFriendsViewModel.shared
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        
                        withAnimation {
                            ConversationGridViewModel.shared.showAllFriends = false
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
                
                Text("Friends")
                    .foregroundColor(.systemBlack)
                    .fontWeight(.semibold)
                
            }
            .frame(width: SCREEN_WIDTH, height: 44)
            .background(Color.backgroundGray)
            .padding(.top, TOP_PADDING)
            
            ScrollView() {
                
                
                VStack(alignment: .leading) {
                    
                    if chats.count > 0 {
                        
                        VStack(spacing: 0) {
                            
                            ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                                FriendCell(chat: chat)
                            }
                            
                        }
                        .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.popUpSystemWhite)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                        
                    } else {
                        
                        HStack {
                            Spacer()
                            FindFriendsView()
                                .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
                                .padding(.bottom, 40)
                            Spacer()
                        }
                    }
                    
                    
                    if let contacts = viewModel.contacts {
                        
                        Text("Contacts")
                            .foregroundColor(.systemBlack)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, chats.count == 0 ? 0 : 28)
                            .padding(.leading, 20)
                        
                        
                        LazyVStack(spacing: 0) {
                            
                            
                            ForEach(Array(contacts.enumerated()), id: \.1.id) { i, contact in
                                
                                ContactCell(contact: contact, index: i)
                                
                            }
                            
                            
                        }
                        .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.popUpSystemWhite)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
                        
                    } else if chats.count > 0 {
                        HStack {
                            Spacer()
                            FindFriendsView()
                                .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
                                .padding(.bottom, 40)
                            Spacer()
                        }
                        
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.backgroundGray)
        .ignoresSafeArea()
        .onAppear {
            self.chats = ConversationGridViewModel.shared.chats.filter({$0.isDm}).sorted(by: {$0.name < $1.name})
            AddFriendsViewModel.shared.setContacts()
        }
    }
}

