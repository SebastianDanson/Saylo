//
//  AddUserToGroupView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI
import Kingfisher
import Combine

struct AddUserToGroupView: View {
    
    @State var searchText: String = ""
    @State var isSearching = false
    
    @StateObject var viewModel = ChatSettingsViewModel.shared
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                
                ZStack {
                    
                    HStack {
                        
                        Button {
                            
                            
                            
                        } label: {
                            
                            Text("Cancel")
                                .foregroundColor(Color(.systemBlue))
                                .padding()
                            
                        }
                        
                        Spacer()
                        
                        
                        Button {
                            
                            
                            
                        } label: {
                            
                            Text("Add")
                                .foregroundColor(Color(.systemBlue))
                                .fontWeight(.medium)
                                .padding()
                            
                        }
                    }
                    
                    
                    Text("Add Friends")
                        .foregroundColor(.systemBlack)
                        .fontWeight(.semibold)
                    
                }
                .frame(height: 44)
                .background(Color.backgroundGray)
                .padding(.top, TOP_PADDING)
                
                SearchBar(text: $searchText, isEditing: $isSearching, isFirstResponder: false, placeHolder: "Search Friends", showSearchReturnKey: false)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                
                
                ScrollView() {
                    
                    VStack(alignment: .leading) {
                        
                        
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
                                
                                AddUserToChatCell(chat: chat)
                                
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
            
     
        }
        .onAppear {
            viewModel.setChats()
        }
    }

}
