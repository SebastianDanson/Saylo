//
//  FriendsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-04-24.
//

import SwiftUI
import Kingfisher

struct FriendsView: View {
    
    @Binding var chats: [Chat]

    let dimension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 60 : 62) : (IS_SMALL_PHONE ? 64 : 66)
    let plusDimension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 31 : 32) : 34
    let fontSize: CGFloat = 14

    var body: some View {
                
        VStack(spacing: 20) {
            
            HStack {
                
                Text("Friends")
                    .font(Font.system(size: IS_SMALL_PHONE ? 17 : 18, weight: .semibold))
                    .foregroundColor(.systemBlack)
                
                Spacer()
                
                Button {
                    withAnimation {
                        ConversationGridViewModel.shared.showAllFriends = true
                    }
                } label: {
                    Text("See All")
                        .font(Font.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.systemBlack)
//                        .foregroundColor(Color(red: 224/255, green: 224/255, blue: 224/255, opacity: 1))
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
                            
                            VStack(spacing: 5) {
                                
                                ZStack {
                                    
                                    Circle()
                                        .strokeBorder(Color.alternateMainBlue, lineWidth: 4)
                                        .frame(width: dimension, height: dimension)
                                    
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: plusDimension, height: plusDimension)
                                        .foregroundColor(.alternateMainBlue)
                                }
                                
                                
                                Text("Add Friend")
                                    .font(Font.system(size: fontSize, weight: .regular))
                                    .foregroundColor(.systemBlack)
                            }
                        }

                                              
                        
                        ForEach(Array(chats.enumerated()), id: \.1.id) { i, chat in
                            
                            if chat.isDm, let imageUrl = URL(string: chat.profileImage) {
                                
                                Button {
                                    ConversationGridViewModel.shared.showChat(chat: chat)
                                } label: {
                                    
                                    VStack(spacing: 5) {
                                        
                                        KFImage(imageUrl)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: dimension, height: dimension)
                                            .clipShape(Circle())
                                        
                                        Text(chat.name)
                                            .font(Font.system(size: fontSize, weight: .regular, design: .rounded))
                                            .foregroundColor(.systemBlack)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                }
            }
        }
        .frame(width: SCREEN_WIDTH)
    }
}
