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
    @State var showMuteOptions = false
    @State var showRemoveGroupAlert = false
    
    @State var name: String
    @State var isMuted: Bool
    @Environment(\.presentationMode) var mode

    let viewModel = ChatSettingsViewModel.shared
    let chat: Chat
    let username: String?
    
    
    init(chat: Chat) {
        self.chat = chat
        self._name = State(initialValue: chat.fullName)
        self._isMuted = State(initialValue: chat.mutedUsers.contains(AuthViewModel.shared.getUserId()))
        
        
        var username: String?
        if chat.isDm {
            if let chatMember = chat.chatMembers.first(where: {$0.id != AuthViewModel.shared.getUserId()}) {
                username = chatMember.username
            }
        }
        
        self.username = username
        
    }
    
    var body: some View {
        
        let removeGroupAlert = Alert(
            title: Text("Are you sure you want to \(chat.isDm ? "remove" : "leave") \(chat.name)?"),
            message: nil,
            primaryButton: .default(
                Text("Cancel"),
                action: {
                    
                }
            ),
            secondaryButton: .destructive(
                Text("Leave"),
                action: {
                    
                    if chat.isDm {
                        viewModel.removeFriend(inChat: chat)
                    } else {
                        viewModel.leaveGroup(chat: chat)
                    }
                    
                    MainViewModel.shared.settingsChat = nil
                    ConversationViewModel.shared.hideChat = true
                }
            )
        )
        
//        NavigationView {
            
            ZStack {
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        ProfileHeaderView(currentImage: chat.profileImage, userName: username ?? "", name: $name,
                                          image: $profileImage)
                            .padding(.top, TOP_PADDING)
                            .padding(.bottom, chat.isDm ? 28 : 0)
                        
                        NavigationLink(destination: AddUserToGroupView().navigationBarHidden(true), isActive: $isAddingFriends) { EmptyView() }
                        NavigationLink(destination: ChatMembersView(showGroupMembers: $showGroupMembers).navigationBarHidden(true), isActive: $showGroupMembers) { EmptyView() }
                        
                        
                        if !chat.isDm {
                            HStack(spacing: 24) {
                                
                                Button {
                                    isAddingFriends = true
                                } label: {
                                    ChatSettingsHeaderButton(imageName: "person.fill.badge.plus", title: "Add",
                                                             leadingPadding: 2, imageDimension: 24, isHighlighted: .constant(false))
                                }
                                
                                Button {
                                    viewModel.toggleMuteForGroup()
                                    isMuted.toggle()
                                } label: {
                                    ChatSettingsHeaderButton(imageName: "bell.fill", title: "Mute",
                                                             leadingPadding: 0, imageDimension: 21, isHighlighted: $isMuted)
                                }
                                
                            }
                            .padding(.bottom, 24)
                        }
                        
                        VStack(spacing: 0) {
                            
                            Button {
                                
                                withAnimation {
                                    
                                    if !ConversationGridViewModel.shared.showConversation, let chat = ConversationGridViewModel.shared.selectedSettingsChat {
                                        ConversationGridViewModel.shared.showChat(chat: chat)
                                    }
                                    
                                    ConversationGridViewModel.shared.selectedSettingsChat = nil
                                    MainViewModel.shared.settingsChat = nil
                                    ConversationViewModel.shared.getSavedPosts()
                                }
                                
                                withAnimation {
                                    ConversationViewModel.shared.getSavedPosts()
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
                                SettingsCell(image: Image("pencil"), imageColor: Color(.systemGreen), title: chat.isDm ? "Edit users name" : "Edit group name",
                                             leadingPadding: 0, imageDimension: 17)
                            }
                            
                            DividerView()
                            
                            if !chat.isDm {
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
                                                 leadingPadding: 0, imageDimension: 21)
                                }
                                
                            }
                            
                            DividerView()
                            
                            Button {
                                withAnimation {
                                    showRemoveGroupAlert = true
                                }
                            } label: {
                                SettingsCell(image: chat.isDm ?  Image(systemName: "person.fill.badge.minus") : Image("leave"),
                                             imageColor: Color(.systemRed),
                                             title: chat.isDm ? "Remove friend" : "Leave group",
                                             leadingPadding: chat.isDm ? -2 : 3, imageDimension: 19)
                            }
                        }
                        .frame(width: SCREEN_WIDTH - 40)
                        .background(Color.popUpSystemWhite)
                        .ignoresSafeArea()
                        .cornerRadius(10)
                        .shadow(color: Color(.init(white: 0, alpha: 0.04)), radius: 16, x: 0, y: 4)
                        
                    }
                }
                //            .padding(.top)
                
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
                    EditChatNameView(chatName: $name, showEditName: $isEditingName)
                }
                
            }
            .alert(isPresented: $showRemoveGroupAlert) {
                removeGroupAlert
            }
            .background(Color.backgroundGray)
//            .ignoresSafeArea()
//        }
        
    }
    
    
    
    func getActionSheet() ->ActionSheet {
        let now = Int(Date().timeIntervalSince1970)
        
        return ActionSheet(title: Text("Mute this chat"),
                           message: Text(""),
                           buttons: [
                            .default(Text("For 15 Minutes")) {
                                viewModel.muteChat(timeLength: (now+900) * 1000)
                            },
                            .default(Text("For 1 Hour")) {
                                viewModel.muteChat(timeLength: (now+3600) * 1000)
                            },
                            .default(Text("For 8 Hours")) {
                                viewModel.muteChat(timeLength: (now+(8*3600)) * 1000)
                                
                            },
                            .default(Text("For 24 Hours")) {
                                viewModel.muteChat(timeLength: (now+86400) * 1000)
                            },
                            .default(Text("Until I turn it back on")) {
                                viewModel.toggleMuteForGroup()
                            },
                            .cancel()
                           ])
        
    }
}

struct ChatSettingsHeaderButton: View {
    
    let imageName: String
    let title: String
    let leadingPadding: CGFloat
    let imageDimension: CGFloat
    
    @Binding var isHighlighted: Bool
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            ZStack {
                
                Circle()
                    .foregroundColor(isHighlighted ? .mainBlue : Color(.systemGray5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isHighlighted ? "bell.slash.fill" : imageName)
                    .resizable()
                    .frame(width: imageDimension, height: imageDimension)
                    .foregroundColor(isHighlighted ? .white : .systemBlack)
                    .padding(.leading, leadingPadding)
                
            }
            
            Text(title)
                .foregroundColor(.systemBlack)
                .font(.system(size: 11))
            
        }
    }
}

