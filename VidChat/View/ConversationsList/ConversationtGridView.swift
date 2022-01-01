
//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-09-26.
//

import SwiftUI
import Kingfisher

enum ConversationStatus {
    case sent, received, receivedOpened, sentOpened, none
}

class TestUser: ObservableObject {
    
    @Published var isSelected = false
    let image: String
    let firstname: String
    let lastname: String
    let id = UUID()
    var conversationStatus: ConversationStatus = .none
    
    init(image: String, firstname: String, lastname: String, conversationStatus: ConversationStatus = .none) {
        self.image = image
        self.firstname = firstname
        self.lastname = lastname
        self.conversationStatus = conversationStatus
    }
}

struct ConversationGridView: View {
    
    private let items = [GridItem(), GridItem(), GridItem()]
    @State private var text = ""
    @State private var searchText = ""
    
    //  @ObservedObject var viewModel: PostGridViewModel
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    @StateObject private var viewModel = ConversationGridViewModel.shared
    
    @State private var photosPickerHeight = PHOTO_PICKER_BASE_HEIGHT
    
    
    var body: some View {
        
        NavigationView {
            
                ZStack(alignment: .top) {
                    
                    if !conversationViewModel.showCamera || viewModel.isSelectingUsers {
                        NavView(searchText: $searchText)
                    }
                    
                    VStack {
                        ZStack(alignment: .top) {
                            
                            if !viewModel.hideFeed {
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                        LazyVGrid(columns: items, spacing: 14, content: {
                                            ForEach(viewModel.users, id: \.id) { user in
                                                ConversationGridCell(user: user)
                                                    .flippedUpsideDown()
                                                    .scaleEffect(x: -1, y: 1, anchor: .center)
                                                    .onTapGesture {
                                                        if viewModel.isSelectingUsers {
                                                            withAnimation(.linear(duration: 0.15)) {
                                                                
                                                            }
                                                        }
                                                    }
                                                    .onLongPressGesture {
                                                        withAnimation {
                                                            CameraViewModel.shared.handleTap()
                                                            conversationViewModel.showCamera = true
                                                        }
                                                    }
                                            }
                                        })
                                            .padding(.horizontal, 12)
                                        
                                    }.padding(.top,
                                              !conversationViewModel.showKeyboard &&
                                              !conversationViewModel.showPhotos &&
                                              !viewModel.showSearchBar &&
                                              !viewModel.isSelectingUsers ?
                                              BOTTOM_PADDING + 82 : viewModel.isSelectingUsers ? (viewModel.selectedUsers.count > 0 ? 12 : BOTTOM_PADDING + 12) : 6)
                                }
                                //                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                                .background(Color.white)
                                .flippedUpsideDown()
                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                .navigationBarTitle("Conversations", displayMode: .inline)
                                .ignoresSafeArea()
                                .zIndex(2)
                                .transition(.move(edge: .bottom))
                                
                            }
                            
                            
                            if conversationViewModel.showCamera {
                                CameraViewModel.shared.cameraView
                                    .transition(.move(edge: .bottom))
                                    .zIndex(viewModel.cameraViewZIndex)
                            }
                        }
                        if conversationViewModel.showPhotos {
                            PhotoPickerView(baseHeight: PHOTO_PICKER_BASE_HEIGHT, height: $photosPickerHeight)
                                .frame(width: SCREEN_WIDTH, height: photosPickerHeight)
                                .transition(.move(edge: .bottom))
                        }
                        
                        if conversationViewModel.showKeyboard {
                            KeyboardView(text: $text)
                        }
                        
                        if viewModel.showSearchBar {
                            Rectangle()
                                .foregroundColor(.white)
                                .frame(height: 2)
                        }
                        
                        if viewModel.selectedUsers.count > 0 && viewModel.isSelectingUsers {
                            SelectedUsersView()
                        }
                    }
                    
                    ZStack(alignment: .bottom) {
                        
                        if !ConversationViewModel.shared.showKeyboard && !viewModel.showSearchBar {
                            
                            VStack {
                                
                                Spacer()
                                
                                OptionsView()
                            }
                            
                        }
                    }
                    
                    if viewModel.showAddFriends {
                        AddFriendsView()
                            .zIndex(3)
                            .transition(.move(edge: .bottom))
                    }
                    
                    if viewModel.showNewChat {
                        NewConversationView()
                            .zIndex(3)
                            .transition(.move(edge: .bottom))
                    }
                }
                .navigationBarHidden(true)
                .zIndex(1)
                .edgesIgnoringSafeArea(conversationViewModel.showKeyboard || viewModel.showSearchBar ? .top : .all)
                
        }
    }
}

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
extension View{
    func flippedUpsideDown() -> some View{
        self.modifier(FlippedUpsideDown())
    }
}

struct ConversationGridView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationGridView()
    }
}

struct ShowCameraView: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.mainBlue)
                .frame(width: 65, height: 65)
                .shadow(color: Color(.init(white: 0, alpha: 0.3)),
                        radius: 12, x: 0, y: 12)
            Image("video")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }
}

struct NavView: View {
    
    @StateObject private var viewModel = ConversationGridViewModel.shared
    @Binding var searchText: String
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    private let toolBarWidth: CGFloat = 38
    
    var body: some View {
        
        ZStack(alignment: .center) {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: topPadding + 50)
                .foregroundColor(.white)
                .shadow(color: Color(white: 0, opacity: (viewModel.users.count > 15 || viewModel.showSearchBar) ? 0.05 : 0), radius: 2, x: 0, y: 2)
            
            if !viewModel.showSearchBar {
                HStack {
                    if !viewModel.isSelectingUsers {
                        
                        HStack(spacing: 12) {
                            
                            Button {
                                viewModel.showSettingsView = true
                            } label: {
                                KFImage(URL(string: AuthViewModel.shared.profileImageUrl ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                viewModel.showSearchBar = true
                            }, label: {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .resizable()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .scaledToFill()
                                    .background(
                                        Circle()
                                            .foregroundColor(.toolBarIconDarkGray)
                                            .frame(width: toolBarWidth - 1, height: toolBarWidth - 1)
                                        
                                    )
                                    .foregroundColor(.toolBarIconGray)
                            })
                        }
                        
                        Spacer()
                        HStack(spacing: 12) {
                            
                            Button {
                                withAnimation {
                                    viewModel.showAddFriends = true
                                }
                            } label: {
                                Circle()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .foregroundColor(.toolBarIconGray)
                                    .overlay(
                                        Image(systemName: "person.fill.badge.plus")
                                            .resizable()
                                            .frame(width: toolBarWidth - 15, height: toolBarWidth - 15)
                                            .scaledToFit()
                                            .foregroundColor(.toolBarIconDarkGray)
                                            .padding(.trailing, 2)
                                            .padding(.top, 1)
                                    )
                            }
                            
                            Button {
                                withAnimation {
                                    viewModel.showNewChat = true
                                }
                            } label: {
                                
                                Circle()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .foregroundColor(.toolBarIconGray)
                                    .overlay(
                                        Image(systemName: "plus.message.fill")
                                            .resizable()
                                            .frame(width: toolBarWidth - 15, height: toolBarWidth - 15)
                                            .scaledToFit()
                                            .foregroundColor(.toolBarIconDarkGray)
                                            .padding(.top, 1)
                                    )
                            }
                        }
                    } else {
                        ZStack {
                            Text("Send To...")
                                .font(.headline)
                            HStack {
                                
                                Button {
                                    withAnimation(.linear(duration: 0.2)) {
                                        viewModel.isSelectingUsers = false
                                        viewModel.hideFeed = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        viewModel.cameraViewZIndex = 3
                                        viewModel.hideFeed = false
                                    }
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: toolBarWidth - 14, height: toolBarWidth - 14)
                                        .foregroundColor(.black)
                                        .padding(.leading, 8)
                                        .padding(.top, -3)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, topPadding)
            } else {
                
                SearchBar(text: $searchText, isEditing: $viewModel.showSearchBar, isFirstResponder: true, placeHolder: "Search")
                    .padding(.horizontal)
                    .padding(.top, topPadding)
                
            }
            
        }.zIndex(2)
            .ignoresSafeArea()
            .popover(isPresented: $viewModel.showSettingsView) {
                ProfileView(user: viewModel.users[0], showSettings: $viewModel.showSettingsView)
            }
    }
}


struct SelectedUsersView: View {
    
    @StateObject private var viewModel = ConversationGridViewModel.shared
    
    var body: some View {
        ZStack {
            
            ZStack() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.selectedUsers.enumerated()), id: \.1.id) { i, user in
                            SelectedUserView(user: user)
                                .padding(.leading, i == 0 ? 20 : 5)
                                .padding(.trailing, i == viewModel.selectedUsers.count - 1 ? 80 : 5)
                                .transition(.scale)
                            
                        }
                    }.padding(.bottom, BOTTOM_PADDING)
                }.frame(width: SCREEN_WIDTH, height: BOTTOM_PADDING + 60)
                
                
                HStack {
                    Spacer()
                    
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .rotationEffect(Angle(degrees: 45))
                        .foregroundColor(Color(.systemGray))
                        .frame(width: 50, height: 50)
                        .background(Circle().frame(width: 40, height: 40).foregroundColor(.white))
                        .scaledToFit()
                        .padding(.horizontal)
                }.padding(.bottom, BOTTOM_PADDING)
            }
            
        }
        .transition(.identity)
    }
}

struct SelectedUserView: View {
    
    let user: TestUser
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 4) {
                
                KFImage(URL(string: user.image))
                    .resizable()
                    .scaledToFill()
                    .background(Color(.systemGray))
                    .frame(width: 44, height: 44)
                    .cornerRadius(44/2)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(user.firstname)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 136/255, green: 137/255, blue: 141/255))
                    .frame(maxWidth: 48)
            }
            
            Button {
                ConversationGridViewModel.shared.removeSelectedUser(withId: user.id)
            } label: {
                ZStack {
                    Circle()
                        .foregroundColor(.toolBarIconGray)
                        .frame(width: 20, height: 20)
                    
                    Image("x")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(white: 0.4, opacity: 1))
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    
                }
                .padding(.top, 4)
                .padding(.trailing, -6)
            }
        }
    }
}
