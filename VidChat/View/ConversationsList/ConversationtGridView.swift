//
//  ChatView.swift
//  Saylo
//
//  Created by Student on 2021-09-26.
//
import SwiftUI
import Kingfisher

enum ConversationStatus {
    case sent, received, receivedOpened, sentOpened, none
}

struct ConversationGridView: View {
    
    private let items = [GridItem(), GridItem(), GridItem()]
    @State private var text = ""
    @State private var searchText = ""
    @State var selection = 0
    
    //  @ObservedObject var viewModel: PostGridViewModel
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    @StateObject private var viewModel = ConversationGridViewModel.shared
    @StateObject private var photosViewModel = PhotosViewModel.shared

    @State var contentOffset: CGFloat = 0
    @State var initialOffset: CGFloat = 0
    @State var showPhotoPickerAlert = false
    
    var body: some View {
        
//        let photoPicker = PhotoPickerView(baseHeight: conversationViewModel.photoBaseHeight,
//                                          height: $conversationViewModel.photoBaseHeight,
//                                          showVideoLengthAlert: $showPhotoPickerAlert)
//            .alert(isPresented: $showPhotoPickerAlert) {videoTooLongAlert()}
        
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                
                NavigationLink(destination: ConversationView().environment(\.colorScheme, .dark)
                                .navigationBarHidden(true), isActive: $viewModel.showConversation) { EmptyView() }
                
                
                NavigationLink(destination: MakeCallView()
                                .navigationBarHidden(true), isActive: $viewModel.isCalling) { EmptyView() }
                
                NavigationLink(destination: EmptyView(), label: {})

                if !conversationViewModel.showCamera || viewModel.isSelectingChats {
                    NavView(searchText: $searchText)
                }
                
                VStack {
                    
                    if viewModel.chats.count < 3 && !conversationViewModel.showCamera && !viewModel.isSelectingChats {
                        
                        FindFriendsView()
                            .shadow(color: Color(.init(white: 0, alpha: 0.08)), radius: 12, x: 0, y: 4)
                            .padding(.top, TOP_PADDING + 56)
                    }
                    
                    
                    ZStack(alignment: .top) {
                        
                        if !viewModel.hideFeed {
                            
                            ScrollView(showsIndicators: false) {
                                
                                VStack {
                                    
                                    LazyVGrid(columns: items, spacing: 12, content: {
                                        
                                        ForEach(Array(viewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                            
                                            ConversationGridCell(chat: $viewModel.chats[i], selectedChatId: .constant(""))
                                                .flippedUpsideDown()
                                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                                .onTapGesture(count: 1, perform: {
                                                    if viewModel.isSelectingChats {
                                                        withAnimation(.linear(duration: 0.15)) {
                                                            viewModel.toggleSelectedChat(chat: chat)
                                                        }
                                                        
                                                    } else {
                                                        conversationViewModel.setChat(chat: chat)
                                                        viewModel.showConversation = true
                                                    }
                                                    MainViewModel.shared.cameraView.stopRunning()
                                                })
                                        }
                                    })
                                        .padding(.horizontal, 20)
                                    
                                    Rectangle()
                                        .frame(width: SCREEN_WIDTH, height: TOP_PADDING + 70)
                                        .foregroundColor(.systemWhite)
                                    
                                }.padding(.top, getConversationGridPadding())
                                
                            }
                            .background(Color.systemWhite)
                            .flippedUpsideDown()
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                            .zIndex(2)
                            .transition(.move(edge: .bottom))
                            
                        }
                        
                        
                        if conversationViewModel.showCamera && !viewModel.isSelectingChats {
                            MainViewModel.shared.cameraView
                                .zIndex(viewModel.cameraViewZIndex)
                        }
                    }
                    
                    
                    if viewModel.isSelectingChats {
                        SelectedChatsView()
                    }
                    
                    if conversationViewModel.showPhotos {
//                        photoPicker
//                            .frame(width: SCREEN_WIDTH, height: conversationViewModel.photoBaseHeight)
//                            .transition(.move(edge: .bottom))
                    }
                    
                    
                    if conversationViewModel.showKeyboard {
                        KeyboardView(text: $text)
                    }
                    
                    if viewModel.showSearchBar {
                        Rectangle()
                            .foregroundColor(.systemWhite)
                            .frame(height: 2)
                    }
                }
                
                ZStack(alignment: .bottom) {
                    
                    if !conversationViewModel.showKeyboard && !viewModel.hasUnreadMessages{
                        
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
                
                if viewModel.showFindFriends {
                    ContactsView()
                        .zIndex(3)
                        .transition(.move(edge: .bottom))
                }
                
                if viewModel.showNewChat {
                    NewConversationView()
                        .zIndex(3)
                        .transition(.move(edge: .bottom))
                }
                
                if viewModel.hasUnreadMessages {
//                    ConversationPlayerView()
//                        .zIndex(3)
//
                }
                
                
            }
            .onAppear(perform: {
                
                if AuthViewModel.shared.isSignedIn {
                                        
                    DispatchQueue.main.async {
                        viewModel.sortChats()
                    }
                    
                    conversationViewModel.showCamera = false
                    conversationViewModel.showPhotos = false
                    conversationViewModel.showKeyboard = false
                    
                }
                
            })
            .alert(isPresented: $photosViewModel.showNoAccessToPhotosAlert) {
                allowPhotosAlert()
            }
            .navigationBarHidden(true)
            .zIndex(1)
            .edgesIgnoringSafeArea(conversationViewModel.showKeyboard || viewModel.showSearchBar ? .top : .all)
            
            
        }.navigationViewStyle(StackNavigationViewStyle())

    }
    
    func getConversationGridPadding() -> CGFloat {
        
        if !conversationViewModel.showKeyboard &&
            !conversationViewModel.showPhotos &&
            !viewModel.showSearchBar &&
            !viewModel.isSelectingChats {
            return BOTTOM_PADDING + 82
        }
        
        if viewModel.isSelectingChats {
            
            //            if viewModel.selectedChats.count > 0 {
            return 12
            //            }
            
        }
        
        return 6
    }
    
    func setSelection() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            if selection == 0 {
                withAnimation {
                    selection = 1
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
            if selection == 1 {
                withAnimation {
                    selection = 2
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 18) {
            if selection == 2 {
                
                withAnimation {
                    selection = 0
                }
            }
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
    
    @StateObject private var viewModel = MainViewModel.shared
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    @StateObject private var cameraViewModel = MainViewModel.shared
    @StateObject private var authViewModel = AuthViewModel.shared
    
    @Binding var searchText: String
    
    private let toolBarWidth: CGFloat = 38
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            VStack {
                
                
                HStack(alignment: .center) {
                    
                        
                        HStack(spacing: 12) {
                            
                            Button {
                                viewModel.showSettingsView = true
                            } label: {
                                KFImage(URL(string: authViewModel.profileImage ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .clipShape(Circle())
                                    .padding(1) // Width of the border
                                    .background(Color.white) // Color of the border
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                withAnimation {
                                    viewModel.isCalling = true
                                }
                            } label: {

                                Circle()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .foregroundColor(.fadedBlack)
                                    .overlay(
                                        Image(systemName: "phone.fill")
                                            .resizable()
                                            .renderingMode(.template)
                                            .scaledToFit()
                                            .frame(height: toolBarWidth - 20)
                                            .foregroundColor(.white)
                                            .padding(.leading, 1)
                                    )
                                    .padding(.leading, -2)
                            }
                            
                            
                        }
                        
                        Spacer()

                        if let chat = conversationViewModel.chat {
                            Text(chat.name)
                                .foregroundColor(.white)
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                      
                        Spacer()
                        
                        HStack(alignment: .top, spacing: 8 ) {
                            
                            Button {
                                
                                withAnimation {
                                    viewModel.showAddFriends = true
                                }
                                
                                AuthViewModel.shared.hasUnseenFriendRequest = false
                                
                            } label: {
                                ZStack {
                                    
                                    Circle()
                                        .frame(width: toolBarWidth, height: toolBarWidth)
                                        .foregroundColor(.fadedBlack)
                                        .overlay(
                                            
                                            Image("plusPerson")
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .frame(height: toolBarWidth - 20)
                                                .foregroundColor(.white)
                                                .padding(.leading, -1)
                                            
                                        )
                                        .padding(.top, -3)
                                    
                                    
                                    if authViewModel.hasUnseenFriendRequest {
                                        
                                        VStack {
                                            HStack {
                                                Spacer()
                                                
                                                Circle()
                                                    .foregroundColor(Color(.systemRed))
                                                    .frame(width: 16, height: 16)
                                                
                                            }
                                            Spacer()
                                        }
                                    }
                                    
                                }.frame(width: toolBarWidth + 6, height: toolBarWidth + 6)
                            }
                            
                            
                            
                            Button {
                                withAnimation {
                                    viewModel.showNewChat = true
                                }
                            } label: {
                                
                                Circle()
                                    .frame(width: toolBarWidth, height: toolBarWidth)
                                    .foregroundColor(.fadedBlack)
                                    .overlay(
                                        Image("pencil")
                                            .resizable()
                                            .renderingMode(.template)
                                            .scaledToFit()
                                            .frame(height: toolBarWidth - 19)
                                            .foregroundColor(.white)
                                            .padding(.top, 0)
                                    )
                            }
                            
                        }
                  
                }
                .padding(.horizontal)
                .padding(.top, TOP_PADDING)
                //                } else {
                //                    SearchBar(text: $searchText, isEditing: $viewModel.showSearchBar, isFirstResponder: true, placeHolder: "Search", showSearchReturnKey: false)
                //                        .padding(.horizontal)
                //                        .padding(.top, TOP_PADDING)
                //
                //                }
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            ProfileView(showSettings: $viewModel.showSettingsView)
        }
        
        .frame(width: SCREEN_WIDTH)
        .padding(.top, 8)
        
    }
}


struct SelectedChatsView: View {
    
    @StateObject private var viewModel = ConversationGridViewModel.shared
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    
    var body: some View {
        
        ZStack {
            
            if viewModel.selectedChats.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(viewModel.selectedChats.enumerated()), id: \.1.id) { i, chat in
                            
                            SelectedChatView(chat: chat)
                                .padding(.leading, i == 0 ? 20 : 5)
                                .padding(.trailing, i == viewModel.selectedChats.count - 1 ? 80 : 5)
                                .transition(.scale)
                            
                        }
                    }.padding(.bottom, getBottomPadding())
                }.frame(width: SCREEN_WIDTH, height: getBottomPadding() + 60)
            } else {
                
                ZStack {
                    
                    Text("Select Chats")
                        .font(.system(size: 18, weight: .medium))
                        .padding(.bottom, getBottomPadding())
                    
                    if conversationViewModel.showPhotos {
                        HStack {
                            
                            Button {
                                
                                withAnimation {
                                    conversationViewModel.showPhotos = false
                                    viewModel.isSelectingChats = false
                                }
                                
                            } label: {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.systemBlack)
                                    .padding(.leading, 12)
                            }
                            
                            
                            Spacer()
                            
                        }
                    }
                }
                
            }
            
            HStack {
                Spacer()
                
                if conversationViewModel.showCamera {
                    Button {
                        withAnimation {
                            
                            viewModel.selectedChats.forEach { chat in
                                conversationViewModel.sendCameraMessage(chatId: chat.id, chat: chat)
                                ConversationService.updateLastVisited(forChat: chat)
                                
                            }
                            
//                            MainViewModel.shared.reset(hideCamera: true)
                            viewModel.cameraViewZIndex = 3
                            viewModel.stopSelectingChats()
                            
                        }
                    } label: {
                        
                        ZStack {
                            
                            Circle().frame(width: 48, height: 48)
                                .foregroundColor(viewModel.selectedChats.count > 0 ? .mainBlue : .lightGray)
                            
                            Image(systemName: "location.north.fill")
                                .resizable()
                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.systemWhite)
                                .padding(.leading, 4)
                                .frame(width: 30, height: 30)
                                .scaledToFit()
                                .padding(.horizontal)
                            
                        }
                        
                    }.disabled(viewModel.selectedChats.count == 0)
                    
                }
            }.padding(.bottom, getBottomPadding())
            
        }.transition(.identity)
        
    }
    
    func getBottomPadding() -> CGFloat {
        
        if conversationViewModel.showKeyboard || conversationViewModel.showPhotos{
            return 2
        } else if conversationViewModel.isRecordingAudio {
            return BOTTOM_PADDING + 80
        }
        
        return BOTTOM_PADDING + 6
    }
}

struct SelectedChatView: View {
    
    let chat: Chat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 4) {
                
                ChatImageCircle(chat: chat, diameter: 44)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(chat.name)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 136/255, green: 137/255, blue: 141/255))
                    .frame(maxWidth: 48)
            }
            
            Button {
                ConversationGridViewModel.shared.removeSelectedChat(withId: chat.id)
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
