
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

struct ConversationGridView: View {
    
    private let items = [GridItem(), GridItem(), GridItem()]
    @State private var text = ""
    @State private var searchText = ""
    @State var selection = 0
    
    //  @ObservedObject var viewModel: PostGridViewModel
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    @StateObject private var viewModel = ConversationGridViewModel.shared
    
    @State var contentOffset: CGFloat = 0
    @State var initialOffset: CGFloat = 0
    @State var recognizeSwipeUp = false
    
    var body: some View {
        
        let photoPicker = PhotoPickerView(baseHeight: conversationViewModel.photoBaseHeight, height: $conversationViewModel.photoBaseHeight)
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                
                NavigationLink(destination: ConversationView()
                                .navigationBarHidden(true), isActive: $viewModel.showConversation) { EmptyView() }
                
                
                NavigationLink(destination: MakeCallView()
                                .navigationBarHidden(true), isActive: $viewModel.isCalling) { EmptyView() }
                
                if !conversationViewModel.showCamera || viewModel.isSelectingChats {
                    NavView(searchText: $searchText)
                    
                }
                
                VStack {
                    
                    if viewModel.chats.count < 10 && !conversationViewModel.showCamera && !viewModel.isSelectingChats {
                        
                        PageView(selection: $selection, indexBackgroundDisplayMode: .always) {
                            
                            FindFriendsView().tag(0)
                            
                            TipView(header: "Tap and Hold on a Chat",
                                    subText: "To start recording a video for that chat",
                                    imageName: "record.circle.fill").tag(1)
                            
                            TipView(header: "Swipe Up",
                                    subText: "To open the video camera",
                                    imageName: "video.fill").tag(2)
                            
                            
                        }
                        .frame(width: SCREEN_WIDTH - 40, height: 300)
                        .shadow(color: Color(.init(white: 0, alpha: 0.08)), radius: 12, x: 0, y: 4)
                        .padding(.top, 20)
                        .onAppear {
                            setSelection()
                        }
                        
                        
                    }
                    
                    
                    ZStack(alignment: .top) {
                        
                        if !viewModel.hideFeed {
                            
                            TrackableScrollView(.vertical, showIndicators: false, contentOffset: $contentOffset, content: {
                                
                                
                                VStack {
                                    LazyVGrid(columns: items, spacing: 14, content: {
                                        ForEach(Array(viewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                            ConversationGridCell(chat: $viewModel.chats[i])
                                                .flippedUpsideDown()
                                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                            //                                                .onTapGesture(count: 2, perform: {
                                            //
                                            //                                                    if !conversationViewModel.showKeyboard {
                                            //                                                        withAnimation {
                                            //                                                            conversationViewModel.showKeyboard = true
                                            //                                                            viewModel.isSelectingChats = true
                                            //                                                            viewModel.toggleSelectedChat(chat: chat)
                                            //                                                        }
                                            //                                                    }
                                            //                                                })
                                                .onTapGesture(count: 1, perform: {
                                                    if viewModel.isSelectingChats {
                                                        withAnimation(.linear(duration: 0.15)) {
                                                            viewModel.toggleSelectedChat(chat: chat)
                                                        }
                                                        
                                                        //                                                        if conversationViewModel.showPhotos {
                                                        ////                                                            photoPicker.setIsSendEnabled()
                                                        //                                                        }
                                                        
                                                    } else {
                                                        conversationViewModel.setChat(chat: chat)
                                                        viewModel.showConversation = true
                                                    }
                                                })
                                                .onLongPressGesture {
                                                    withAnimation {
                                                        CameraViewModel.shared.handleTap()
                                                        conversationViewModel.selectedChat = chat
                                                        conversationViewModel.chatId = chat.id
                                                        conversationViewModel.showCamera = true
                                                    }
                                                }
                                        }
                                    })
                                        .padding(.horizontal, 12)
                                    
                                }.padding(.top, getConversationGridPadding())
                                    .onChange(of: contentOffset, perform: { value in
                                        // Do something
                                        if recognizeSwipeUp && !conversationViewModel.showCamera {
                                            if initialOffset == 0 && contentOffset < 0 {
                                                initialOffset = contentOffset
                                            }
                                        
                                            print(contentOffset)
                                            if contentOffset > initialOffset && contentOffset < 0{
                                                withAnimation {
                                                    conversationViewModel.showCamera = true
                                                }
                                            }
                                        }
                                    })
                                
                            })
                                .background(Color.systemWhite)
                                .flippedUpsideDown()
                                .scaleEffect(x: -1, y: 1, anchor: .center)
                                .zIndex(2)
                                .transition(.move(edge: .bottom))
                                .onAppear {
                                    recognizeSwipeUp = false
                                    initialOffset = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        recognizeSwipeUp = true
                                    }
                                }
                            
                            
                            
                            
                        }
                        
                        
                        if conversationViewModel.showCamera && !viewModel.isSelectingChats {
                            CameraViewModel.shared.cameraView
                                .zIndex(viewModel.cameraViewZIndex)
                                .transition(.move(edge: .bottom))
                            //                                .overlay(
                            //                                    VStack {
                            //                                        Spacer()
                            //
                            //                                        SelectUsersPopUpView()
                            //                                    }
                            //                                )
                        }
                    }
                    
                    
                    if viewModel.isSelectingChats {
                        SelectedChatsView()
                    }
                    
                    if conversationViewModel.showPhotos {
                        photoPicker
                            .frame(width: SCREEN_WIDTH, height: conversationViewModel.photoBaseHeight)
                            .transition(.move(edge: .bottom))
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
            .onAppear {}
            
        }
    }
    
    func getConversationGridPadding() -> CGFloat {
        
        if !conversationViewModel.showKeyboard &&
            !conversationViewModel.showPhotos &&
            !viewModel.showSearchBar &&
            !viewModel.isSelectingChats {
            return BOTTOM_PADDING + 90
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
    
    @StateObject private var viewModel = ConversationGridViewModel.shared
    @StateObject private var conversationViewModel = ConversationViewModel.shared
    @StateObject private var cameraViewModel = CameraViewModel.shared
    @StateObject private var authViewModel = AuthViewModel.shared
    
    @Binding var searchText: String
    
    private let toolBarWidth: CGFloat = 38
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            VStack {
                
                if !viewModel.showSearchBar {
                    
                    HStack(alignment: .top) {
                        
                        if !viewModel.isSelectingChats {
                            
                            HStack(spacing: 12) {
                                
                                Button {
                                    viewModel.showSettingsView = true
                                } label: {
                                    KFImage(URL(string: authViewModel.profileImageUrl ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: toolBarWidth, height: toolBarWidth)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: {
                                    cameraViewModel.toggleIsFrontFacing()
                                }, label: {
                                    
                                    if cameraViewModel.isRotating {
                                        
                                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                                            .resizable()
                                            .foregroundColor(.toolBarIconDarkGray)
                                            .scaledToFit()
                                            .frame(width: toolBarWidth - 8, height: toolBarWidth - 8)
                                        
                                    } else {
                                        Image(cameraViewModel.isFrontFacing ? "frontCamera" : "rearCamera")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.toolBarIconDarkGray)
                                            .scaledToFit()
                                            .frame(width: toolBarWidth - 8, height: toolBarWidth - 8)
                                    }
                                    
                                })
                            }
                            
                            Spacer()
                            HStack(alignment: .top, spacing: 14) {
                                
                                Button {
                                    withAnimation {
                                        viewModel.showAddFriends = true
                                    }
                                    AuthViewModel.shared.currentUser?.hasUnseenFriendRequest = false
                                } label: {
                                    ZStack {
                                        
                                        Circle()
                                            .frame(width: toolBarWidth, height: toolBarWidth)
                                            .foregroundColor(.toolBarIconGray)
                                            .overlay(
                                                
                                                Image(systemName: "person.fill.badge.plus")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .scaledToFit()
                                                    .frame(height: toolBarWidth - 15)
                                                    .foregroundColor(.toolBarIconDarkGray)
                                                    .padding(.leading, -1)
                                                
                                            )
                                            .padding(.top, -3)
                                        
                                        
                                        if AuthViewModel.shared.currentUser?.hasUnseenFriendRequest ?? false {
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
                                        viewModel.isCalling = true
                                    }
                                } label: {
                                    
                                    Circle()
                                        .frame(width: toolBarWidth, height: toolBarWidth)
                                        .foregroundColor(.toolBarIconGray)
                                        .overlay(
                                            Image(systemName: "phone.fill")
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .frame(height: toolBarWidth - 18)
                                                .foregroundColor(.toolBarIconDarkGray)
                                                .padding(.leading, 1)
                                        )
                                        .padding(.leading, -2)
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
                                            Image("pencil")
                                                .resizable()
                                                .renderingMode(.template)
                                                .scaledToFit()
                                                .frame(height: toolBarWidth - 18)
                                                .foregroundColor(.toolBarIconDarkGray)
                                                .padding(.top, 0)
                                        )
                                }
                                
                            }
                        } else {
                            ZStack {
                                Text("Send To...")
                                    .font(.headline)
                                HStack {
                                    
                                    if conversationViewModel.showCamera {
                                        Button {
                                            withAnimation(.linear(duration: 0.2)) {
                                                viewModel.stopSelectingChats()
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
                                                .foregroundColor(.systemBlack)
                                                .padding(.leading, 8)
                                                .padding(.top, -3)
                                        }
                                    }
                                    Spacer()
                                }
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, TOP_PADDING)
                } else {
                    SearchBar(text: $searchText, isEditing: $viewModel.showSearchBar, isFirstResponder: true, placeHolder: "Search", showSearchReturnKey: false)
                        .padding(.horizontal)
                        .padding(.top, TOP_PADDING)
                    
                }
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showSettingsView) {
            ProfileView(showSettings: $viewModel.showSettingsView)
        }
        .frame(width: SCREEN_WIDTH, height: conversationViewModel.showKeyboard ? TOP_PADDING + 40 : TOP_PADDING + 50)
        .background(Color.systemWhite)
        .zIndex(2)
        .ignoresSafeArea()
        
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
                Text("Select Chats")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.bottom, getBottomPadding())
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
                            
                            CameraViewModel.shared.reset(hideCamera: true)
                            viewModel.cameraViewZIndex = 3
                            viewModel.stopSelectingChats()
                            
                        }
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(viewModel.selectedChats.count > 0 ? .mainBlue : .lightGray)
                            .frame(width: 50, height: 50)
                            .background(Circle().frame(width: 40, height: 40).foregroundColor(.systemWhite))
                            .scaledToFit()
                            .padding(.horizontal)
                    }.disabled(viewModel.selectedChats.count == 0)
                    
                }
            }.padding(.bottom, getBottomPadding())
            
        }.transition(.identity)
        
    }
    
    func getBottomPadding() -> CGFloat {
        
        if conversationViewModel.showKeyboard {
            return 2
        } else if conversationViewModel.isRecordingAudio {
            return BOTTOM_PADDING + 80
        }
        
        return BOTTOM_PADDING
    }
}

struct SelectedChatView: View {
    
    let chat: Chat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 4) {
                
                ChatImage(chat: chat, diameter: 44)
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


