//
//  ChatSettingsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-14.
//

import SwiftUI

struct ChatSettingsView: View {
    
    @State var profileImage: UIImage?
    @State var showImageCropper = false
    @State var showImagePicker = false
    @State var isAddingFriends = false
    @State var isEditingName = false
    @State var showGroupMembers = false

    @Binding var showSettings: Bool
    @State var name: String

    let viewModel = ChatSettingsViewModel.shared
    //
    let chat: Chat
    
    
    init(chat: Chat, showSettings: Binding<Bool>) {
        self._showSettings = showSettings
        self.chat = chat
        self._name = State(initialValue: chat.name)
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 16) {
                    
                    ProfileHeaderView(currentImage: chat.profileImageUrl, userName: "", name: $name,
                                      image: $profileImage, showSettings: $showSettings)
                    
                    NavigationLink(destination: AddUserToGroupView().navigationBarHidden(true), isActive: $isAddingFriends) { EmptyView() }
                    NavigationLink(destination: ChatMembersView(showGroupMembers: $showGroupMembers).navigationBarHidden(true), isActive: $showGroupMembers) { EmptyView() }

                    HStack(spacing: 20) {
                        Button {
                            isAddingFriends = true
                        } label: {
                            ChatSettingsHeaderButton(imageName: "person.fill.badge.plus", title: "Add", leadingPadding: 2, imageDimension: 22)
                        }

                        ChatSettingsHeaderButton(imageName: "bell.fill", title: "Mute", leadingPadding: 0, imageDimension: 18)
                        
                    }.padding(.bottom, 8)
                    
                    VStack(spacing: 0) {
                        
                        Button {
                            if ConversationViewModel.shared.savedMessages.count == 0 {
                                ConversationViewModel.shared.fetchSavedMessages()
                            }
                            
                            showSettings = false
                            
                            withAnimation {
                                ConversationViewModel.shared.showSavedPosts = true
                            }
                            
                        } label: {
                            SettingsCell(image: Image(systemName: "bookmark.fill"), imageColor: Color(.mainBlue), title: "View saved messages",
                                         leadingPadding: 0, imageDimension: 17)
                        }
                        
                        DividerView()
                        
                        Button {
                            withAnimation {
                                isEditingName = true
                            }
                        } label: {
                            SettingsCell(image: Image("pencil"), imageColor: Color(.systemGreen), title: "Edit group name",
                                         leadingPadding: 0, imageDimension: 17)
                        }
                        
                        DividerView()
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            SettingsCell(image: Image(systemName: "photo.fill"), imageColor: Color(.systemOrange), title: "Edit group image",
                                         leadingPadding: 0, imageDimension: 17)
                        }.sheet(isPresented: $showImagePicker, content: {
                            ImagePicker(image: $profileImage, showImageCropper: $showImageCropper)
                        })
                        
                        
                        DividerView()
                        
                        
                        Button {
                            showGroupMembers = true
                        } label: {
                            SettingsCell(image: Image(systemName: "person.2.fill"), imageColor: .mainBlue, title: "See group Members",
                                         leadingPadding: 2, imageDimension: 22)
                        }
                        
                        
                    }
                    .frame(width: SCREEN_WIDTH - 40)
                    .background(Color.popUpSystemWhite)
                    .ignoresSafeArea()
                    .cornerRadius(10)
                    .shadow(color: Color(.init(white: 0, alpha: 0.04)), radius: 16, x: 0, y: 4)
                }
            }
            .padding(.top)
            
            if showImageCropper {
                ImageCropper(image: $profileImage, showImageCropper: $showImageCropper, showImagePicker: $showImagePicker, onDone: {
                    if let profileImage = profileImage {
                        viewModel.updateProfileImage(image: profileImage)
                    }
                })
                    .ignoresSafeArea()
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
            
            if isEditingName {
                EditChatNameView(chatName: "Seb", showEditName: $isEditingName)
            }

        }.background(Color.backgroundGray)
        
    }
}

struct ChatSettingsHeaderButton: View {
    
    let imageName: String
    let title: String
    let leadingPadding: CGFloat
    let imageDimension: CGFloat

    var body: some View {
        
        VStack(spacing: 4) {
            
            ZStack {
                
                Circle()
                    .foregroundColor(.toolBarIconGray)
                    .frame(width: 36, height: 36)
                
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: imageDimension, height: imageDimension)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, leadingPadding)
                
            }
            
            Text(title)
                .foregroundColor(.systemBlack)
                .font(.system(size: 11))
            
        }
    }
}

//struct ChatSettingsView: View {
//
//    let chat: Chat
//
//    var body: some View {
//
//        VStack(spacing: 20) {
//
//            HStack(alignment: .center) {
//
//                HStack(spacing: 12) {
//
//                    ChatImage(chat: chat, diameter: 36)
//
//                    Text(chat.name)
//                        .lineLimit(1)
//                        .font(.system(size: 18, weight: .semibold))
//                }
//
//                Spacer()
//
//                ZStack {
//
//                    Circle()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.iconSystemWhite)
//
//                    Image(systemName: "video")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(.systemWhite)
//                        .frame(width: 22, height: 22)
//
//                }.padding(.trailing, 20)
//
//            }
//            .padding(.leading)
//            .padding(.top)
//
//
//
//            Button {
//
//                if ConversationViewModel.shared.savedMessages.count == 0 {
//                    ConversationViewModel.shared.fetchSavedMessages()
//                }
//
//                withAnimation {
//                    ConversationViewModel.shared.showSavedPosts = true
//                }
//            } label: {
//                HStack(alignment: .center) {
//                    HStack(spacing: 4) {
//
//                        Image(systemName: "bookmark.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(Color.systemBlack)
//                            .frame(width: 36, height: 20)
//                            .padding(.leading, 8)
//
//                        Text("View saved messages")
//                            .lineLimit(1)
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.systemBlack)
//                    }
//
//                    Spacer()
//
//                    Image(systemName: "chevron.right")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(Color(.systemGray2))
//                        .frame(width: 40, height: 20)
//                        .padding(.trailing, 2)
//                }
//                .padding(.vertical)
//                .background(Color.systemWhite)
//                .cornerRadius(12)
//                .padding(.horizontal)
//            }
//
//        }
//        .padding(.vertical)
//        .background(Color(.systemGray6))
//        .cornerRadius(20)
//        .padding(.leading)
//        .padding(.bottom)
//        .shadow(color: Color(.init(white: 0, alpha: 0.2)), radius: 16, x: 0, y: 8)
//    }
//}
