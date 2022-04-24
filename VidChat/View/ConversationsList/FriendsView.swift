//
//  FriendsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-24.
//

import SwiftUI
import Kingfisher

struct FriendsView: View {
    
    @State var chats = [Chat]()

    
    var body: some View {
                
        VStack(spacing: 24) {
            
            HStack {
                
                Text("Friends")
                    .font(Font.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    withAnimation {
                        ConversationGridViewModel.shared.showAllFriends = true
                    }
                } label: {
                    Text("See All")
                        .font(Font.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 224/255, green: 224/255, blue: 224/255, opacity: 1))
                }

            }
            .padding(.leading, 20)
            .padding(.trailing, 12)
            
            HStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 18) {
                        
                        Button {
                            withAnimation {
                                ConversationGridViewModel.shared.showAddFriends = true
                            }
                        } label: {
                            VStack(spacing: 7) {
                                
                                ZStack {
                                    
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 4)
                                        .frame(width: 66, height: 66)
                                    
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 34, height: 34)
                                        .foregroundColor(.white)
                                }
                                
                                
                                Text("Add Friend")
                                    .font(Font.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }

                                              
                        
                        ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                            
                            if chat.isDm, let imageUrl = URL(string: chat.profileImage) {
                                
                                Button {
                                    ConversationGridViewModel.shared.showChat(chat: chat)
                                } label: {
                                    
                                    VStack(spacing: 7) {
                                        
                                        KFImage(imageUrl)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 66, height: 66)
                                            .clipShape(Circle())
                                        
                                        Text(chat.name)
                                            .font(Font.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                }
            }
        }.onAppear {
            self.chats = ConversationGridViewModel.shared.chats.shuffled()
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
