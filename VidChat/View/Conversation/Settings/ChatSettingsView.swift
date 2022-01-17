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

    @Binding var showSettings: Bool
    @State var name: String
    @State var isMuted: Bool
    let viewModel = ChatSettingsViewModel.shared
    //
    let chat: Chat
    
    
    init(chat: Chat, showSettings: Binding<Bool>) {
        self._showSettings = showSettings
        self.chat = chat
        self._name = State(initialValue: chat.name)
        self._isMuted = State(initialValue: chat.mutedUsers.contains(AuthViewModel.shared.getUserId()))
    }
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    ProfileHeaderView(currentImage: chat.profileImageUrl, userName: "", name: $name,
                                      image: $profileImage, showSettings: $showSettings)
                        .padding(.top, TOP_PADDING)
                    
                    NavigationLink(destination: AddUserToGroupView().navigationBarHidden(true), isActive: $isAddingFriends) { EmptyView() }
                    NavigationLink(destination: ChatMembersView(showGroupMembers: $showGroupMembers).navigationBarHidden(true), isActive: $showGroupMembers) { EmptyView() }
                    
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
                    .padding(.top, 20)
                    
                    VStack(spacing: 0) {
                        
                        Button {
                            if ConversationViewModel.shared.savedMessages.count == 0 {
                                ConversationViewModel.shared.fetchSavedMessages()
                            }
                            
                            withAnimation {
                                showSettings = false
                            }
                            
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
                EditChatNameView(chatName: chat.name, showEditName: $isEditingName)
            }
            
        }
//        .actionSheet(isPresented: $showMuteOptions, content: {
//            getActionSheet()
//        })
        .background(Color.backgroundGray)
        .ignoresSafeArea()
        
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

