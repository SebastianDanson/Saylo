//
//  CameraMainView.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//

import SwiftUI
import Kingfisher
import AVFoundation

struct MainView: View {
    
    @StateObject var viewModel = MainViewModel.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared
    
    @State private var searchText = ""
    @State private var noteText = ""
    @State var isTyping = false
    @State var showAllowAudioAlert = false
    @State var showAllowCameraAccessAlert = false
    
    var cameraView = CameraView()
    let bottomPadding: CGFloat = IS_SMALL_PHONE ? 4 : 8
    
    var body: some View {
        
        
        
        ZStack(alignment: .center) {
            
            Color.black.ignoresSafeArea()
            
            //The photo that was just taken
            if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                TakenPhotoView(photo: photo)
            }
            
            //Camera view shown when recording video or taking photo
            if viewModel.showCamera() {
                cameraView.onTapGesture(count: 2, perform: { switchCamera() })
            }
            
            // Voice view
            if viewModel.selectedView == .Voice {
                VoiceView()
            }
            
            //Note View
            if viewModel.selectedView == .Note {
                NoteView(noteText: $noteText)
            }
            
            //Saylo View
            if viewModel.selectedView == .Saylo {
                ConversationPlayerView()
            }
            
            if viewModel.showPhotos {
                PhotosView()
            }
            
            ZStack {
                
                //                ZStack {
                //                    if !IS_SMALL_PHONE {
                VStack {
                    Spacer()
                    
                    UnreadMessagesScrollView(selectedView: $viewModel.selectedView)
                        .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET - MINI_MESSAGE_HEIGHT - 4)
                }
                //                    }
                //
                //                    VStack {
                //                        Spacer()
                //
                //                        if !(IS_SMALL_PHONE && viewModel.selectedView == .Saylo) {
                //                            ChatsView(selectedView: $viewModel.selectedView, dragOffset: $viewModel.chatsViewDragOffset)
                //                                .background(Color.init(white: 0, opacity: IS_SMALL_PHONE ? 0.5 : 0.0))
                //                        }
                //                    }
                //                }
                //                .zIndex(viewModel.chatsViewDragOffset != .zero ? 4 : 1)
                
                //Camera Flash View
                if viewModel.isRecording && viewModel.isFrontFacing && viewModel.hasFlash {
                    FlashView().zIndex(2)
                }
                
                //Overlay Buttons
                VStack(spacing: 6) {
                    
                    
                    Spacer()
                    
                    ZStack {
                        
                        //Recording voice or video
                        if viewModel.showRecordButton() {
                            Button {
                                viewModel.handleRecordButtonTapped()
                                
                                if viewModel.selectedView == .Voice {
                                    viewModel.selectedView = .Video
                                }
                            } label: {
                                RecordButton()
                            }
                            .overlay(
                                ZStack {
                                    if viewModel.isRecording && viewModel.selectedView != .Voice  {
                                        SwitchCameraView()
                                    }
                                }
                            )
                        }
                        
                        //Taking Photo
                        if viewModel.selectedView == .Photo {
                            Button {
                                viewModel.handlePhotoButtonTapped()
                            } label: {
                                PhotoButton(photo: $viewModel.photo)
                            }
                            .overlay(SwitchCameraView())
                        }
                        
                        
                        if viewModel.photo != nil {
                            //The Buttons on either of the photo button
                            TakenPhotoOptions()
                        }
                        
                    }.padding(.bottom, bottomPadding)
                    
                    
                    VStack(spacing: 0) {
                        
                        ZStack {
                            if !viewModel.isRecording && !viewModel.showPhotos && viewModel.selectedView != .Saylo {
                                
                                HStack {
                                    //
                                    Button {
                                        viewModel.showPhotos = true
                                    } label: {
                                        LastPhotoView()
                                    }
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedView != .Photo {
                                        MessageOptions(type: $viewModel.selectedView, isRecording: $viewModel.isRecording)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        MainViewModel.shared.cameraView.switchCamera()
                                    } label: {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .resizable()
                                            .font(Font.title.weight(.semibold))
                                            .scaledToFit()
                                            .frame(height: 35)
                                            .foregroundColor(.white)
                                            .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                    }
                                    .frame(width: IS_SMALL_WIDTH ? 30 : 36, height: 35)
                                    
                                }
                                .padding(.horizontal, IS_SMALL_WIDTH ? 12 : 20)
                                .frame(width: SCREEN_WIDTH)
                                .padding(.bottom, bottomPadding + (IS_SMALL_PHONE ? 2 : 0))
                                
                            }
                            
                            
                            
                            if viewModel.isRecording || viewModel.selectedView == .Photo {
                                CancelRecordingButton(bottomPadding: bottomPadding)
                                    .zIndex(6)
                                
                            }
                        }
                        
                        //                        if IS_SMALL_PHONE {
                        //                            if !viewModel.isRecording && !viewModel.showPhotos {
                        //                                let normalPadding = CHATS_VIEW_HEIGHT + MESSAGE_HEIGHT + TOP_PADDING - SCREEN_HEIGHT
                        //                                UnreadMessagesScrollView(selectedView: $viewModel.selectedView)
                        //                                    .padding(.bottom, viewModel.selectedView == .Saylo ?
                        //                                             normalPadding - SMALL_PHONE_SAYLO_HEIGHT - TOP_PADDING - (SCREEN_WIDTH < 350 ? 20 : 0) : normalPadding)
                        //                            }
                        //                        }
                    }
                }
                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET)
                .zIndex(3)
                
                VStack {
                    
                    HStack {
                        
                        if viewModel.selectedView != .Saylo {
                            Button {
                                ConversationGridViewModel.shared.showConversation = false
                            } label: {
                                Image("x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: IS_SMALL_WIDTH ? 24 : 28, height: IS_SMALL_WIDTH ? 24 : 28)
                                    .shadow(color: Color(white: 0, opacity: 0.2), radius: 4, x: 0, y: 4)
                                
                            }
                            .frame(width: IS_SMALL_WIDTH ? 30 : 34, height: IS_SMALL_WIDTH ? 30 : 34)
                            
                            
                            Spacer()
                            
                            
                            if let chat = ConversationViewModel.shared.chat {
                                
                                Text(chat.name)
                                    .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: Color(white: 0, opacity: 0.1), radius: 4, x: 0, y: 4)
                                
                                
                                Spacer()
                                
                            
                                Button {
                                    withAnimation {
                                        MainViewModel.shared.settingsChat = chat
                                    }
                                } label: {
                                    KFImage(URL(string: chat.profileImage))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: IS_SMALL_WIDTH ? 30 : 34, height: IS_SMALL_WIDTH ? 30 : 34)
                                        .shadow(color: Color(white: 0, opacity: 0.2), radius: 4, x: 0, y: 4)
                                        .clipShape(Circle())
                                        .padding(1) // Width of the border
                                        .background(Color.white) // Color of the border
                                        .clipShape(Circle())
                                }
                                
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, TOP_PADDING + 12)
                    
                    Spacer()
                }
            }
            .zIndex(3)
            
            
            //            Group {
            //                if viewModel.showAddFriends {
            //                    AddFriendsView()
            //                        .zIndex(5)
            //                        .transition(.move(edge: .bottom))
            //                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            //                        .cornerRadius(14)
            //                }
            //
            //                if viewModel.showFindFriends {
            //                    ContactsView()
            //                        .zIndex(5)
            //                        .transition(.move(edge: .bottom))
            //                        .frame(width: SCREEN_WIDTH)
            //                        .cornerRadius(14)
            //                }
            //
            //                if viewModel.showNewChat {
            //                    NewConversationView()
            //                        .zIndex(5)
            //                        .transition(.move(edge: .bottom))
            //                        .frame(width: SCREEN_WIDTH)
            //                        .cornerRadius(14)
            //                }
            //
                            if let chat = viewModel.settingsChat {
                                ChatSettingsView(chat: chat)
                                    .zIndex(5)
                                    .transition(.move(edge: .bottom))
                                    .frame(width: SCREEN_WIDTH)
                                    .cornerRadius(14)
                            }
            //
            //                if viewModel.isCalling {
            //                    MakeCallView()
            //                        .zIndex(5)
            //                        .transition(.move(edge: .bottom))
            //                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            //                        .cornerRadius(14)
            //                }
            //            }
            
            if let message = viewModel.selectedMessage {
                MessageOptionsView(message: message).zIndex(6)
            }
        }
        .overlay(
            ZStack {
                
                
                //NavView
                //                if !viewModel.isRecording && viewModel.selectedView != .Note && viewModel.selectedView != .Photo && viewModel.selectedView != .Saylo && !viewModel.showNewChat && !viewModel.isCalling && !viewModel.showAddFriends && viewModel.settingsChat == nil{
                //
                //                    VStack {
                //                        NavView(searchText: $searchText)
                //                        Spacer()
                //                    }
                //
                //                } else
                if viewModel.isRecording {
                    VStack {
                        RecordTimerView()
                            .padding(.top, TOP_PADDING_OFFSET + 8)
                        Spacer()
                    }
                }
                
            }
        )
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
        //        .onAppear {
        //            cameraView.startRunning()
        //        }
        
    }
    
    
    //Camera functions
    
    func switchCamera() {
        cameraView.switchCamera()
    }
    
    func startRecording() {
        cameraView.startRecording()
    }
    
    func stopRecording() {
        cameraView.stopRecording()
    }
    
    func cancelRecording() {
        cameraView.cancelRecording()
    }
    
    func takePhoto() {
        let hasFlash = MainViewModel.shared.hasFlash
        cameraView.takephoto(withFlash: hasFlash)
    }
    
    func setupSession() {
        cameraView.setupSession()
    }
    
    func setupProfileImageCamera() {
        cameraView.setupProfileImageCamera()
    }
    
    func stopSession() {
        cameraView.stopSession()
    }
    
    func startRunning() {
        cameraView.startRunning()
    }
    
    func stopRunning() {
        cameraView.stopRunning()
    }
    
}

struct FlashView: View {
    var body: some View {
        Rectangle()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .foregroundColor(Color(.init(white: 1, alpha: 0.7)))
            .edgesIgnoringSafeArea(.all)
    }
}

struct SwitchCameraView: View {
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                MainViewModel.shared.cameraView.switchCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .font(Font.title.weight(.semibold))
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.white)
                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                    .padding(.trailing, 16)
            }
        }
        .frame(width: SCREEN_WIDTH)
    }
}

struct TakenPhotoView: View {
    
    var photo: UIImage
    
    var body: some View {
        
        VStack {
            
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: CAMERA_WIDTH, height: MESSAGE_HEIGHT)
                .cornerRadius(14, corners: [.topRight, .topLeft])
                .padding(.top, TOP_PADDING_OFFSET)
            
            Spacer()
            
        }.zIndex(3)
    }
}

struct VoiceView: View {
    
    var body: some View {
        
        VStack {
            
            VStack {
                
                Spacer()
                
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.white)
                
                
                Spacer()
                
            }
            .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT + TOP_PADDING)
            .background(Color.alternateMainBlue)
            
            Spacer()
        }
    }
}

struct PhotosView: View {
    
    @StateObject var viewModel = MainViewModel.shared
    @State var showPhotoPickerAlert = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            PhotoPickerView(baseHeight: viewModel.photoBaseHeight, height: $viewModel.photoBaseHeight, showVideoLengthAlert: $showPhotoPickerAlert)
                .frame(width: SCREEN_WIDTH, height: viewModel.photoBaseHeight * 2)
                .alert(isPresented: $showPhotoPickerAlert) {videoTooLongAlert()}
                .overlay(
                    
                    Button(action: {
                        viewModel.showPhotos = false
                    }, label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 56, height: 56)
                                .foregroundColor(Color(white: 0, opacity: 0.5))
                            
                            Image("x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    })
                    , alignment: .bottomTrailing
                )
                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET)
                .alert(isPresented: $viewModel.showAllowPhotoAccessAlert) { allowPhotosAlert() }
            
        }
    }
}


struct NoteView: View {
    
    @Binding var noteText: String
    //    @Binding var isTyping: Bool
    
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                if noteText.isEmpty {
                    
                    Text("Start typing...")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                
                MultilineTextField(text: $noteText, height: MESSAGE_HEIGHT)
                    .frame(width: SCREEN_WIDTH - 40)
                
                
                VStack {
                    
                    HStack {
                        
                        Button {
                            MainViewModel.shared.selectedView = .Video
                            noteText = ""
                        } label: {
                            Image("x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding(.leading)
                                .padding(.top, TOP_PADDING + 40 + (IS_SMALL_PHONE ? 50 : 0))
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            }
            .frame(width: SCREEN_WIDTH, height: MESSAGE_HEIGHT + TOP_PADDING)
            .background(Color.alternateMainBlue)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
            Spacer()
        }
    }
}


struct PhotoButton: View {
    
    @Binding var photo: UIImage?
    
    var body: some View {
        
        ZStack {
            
            if photo == nil {
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .frame(width: 62, height: 62)
                
                Circle()
                    .frame(width: 54, height: 54)
                    .foregroundColor(.white)
            } else {
                SendButton()
            }
        }
    }
}

struct SendButton: View {
    
    var body: some View {
        ZStack {
            
            Circle()
                .frame(width: 64, height: 64)
                .foregroundColor(.white)
            
            Image(systemName: "chevron.forward")
                .resizable()
                .scaledToFit()
                .font(Font.title.weight(.semibold))
                .frame(width: 32, height: 32)
                .foregroundColor(.alternateMainBlue)
                .padding(.leading, 4)
            
        }
    }
}

struct PhotoLibraryAndSwitchCameraView: View {
    
    @StateObject var viewModel = MainViewModel.shared
    var cameraView: CameraView
    
    
    var body: some View {
        
        HStack {
            
            if !viewModel.isRecording {
                
                Button {
                    withAnimation {
                        viewModel.showPhotos = true
                    }
                } label: {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.white)
                }
                
            } else {
                
                Button {
                    if viewModel.selectedView == .Voice {
                        viewModel.audioRecorder.cancelRecording()
                        viewModel.cancelRecording()
                    } else {
                        viewModel.cancelRecording()
                    }
                } label: {
                    
                    Image(systemName: "x.circle")
                        .resizable()
                        .font(Font.title.weight(.medium))
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                }
            }
            
            Spacer()
            
            Button {
                cameraView.switchCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .font(Font.title.weight(.semibold))
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            
            
        }.frame(width: 240)
    }
}

struct CancelRecordingButton: View {
    
    let viewModel = MainViewModel.shared
    let bottomPadding: CGFloat
    
    var body: some View {
        
        Button {
            if viewModel.selectedView == .Voice {
                viewModel.audioRecorder.cancelRecording()
                viewModel.cancelRecording()
                viewModel.selectedView = .Video
            } else if viewModel.selectedView == .Photo {
                viewModel.photo = nil
                viewModel.selectedView = .Video
            } else  {
                viewModel.cancelRecording()
            }
        } label: {
            Image("x")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: IS_SMALL_WIDTH ? 24 : 28, height: IS_SMALL_WIDTH ? 24 : 28)
                .shadow(color: Color(white: 0, opacity: 0.2), radius: 4, x: 0, y: 4)
        }
        .frame(width: 36, height: 36)
        .padding(.bottom, bottomPadding + (IS_SMALL_PHONE && viewModel.isRecording ? (SCREEN_WIDTH < 350 ? 36 : 24) : 0))
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
    }
}

//Chats scroll view at bottom of screen
struct ChatsView: View {
    
    private let items = [GridItem(), GridItem(), GridItem(), GridItem()]
    
    @StateObject var conversationViewModel = ConversationViewModel.shared
    @StateObject private var gridviewModel = ConversationGridViewModel.shared
    @Binding var selectedView: MainViewType
    @Binding var dragOffset: CGSize
    
    let maxHeight = -CHATS_VIEW_HEIGHT * 2 - 4
    let backgroundColor = Color(red: 48/255, green: 54/255, blue: 64/255)
    
    var body: some View {
        
        ZStack {
            
            if !conversationViewModel.showSavedPosts {
                
                backgroundColor.ignoresSafeArea()
                
                
                VStack {
                    
                    if dragOffset == .zero {
                        
                        LazyVGrid(columns: items, spacing: 0, content: {
                            
                            if gridviewModel.chats.count > 0 {
                                
                                ForEach(Array(gridviewModel.chats[0...min(gridviewModel.chats.count - 1, 3)].enumerated()), id: \.1.id) { i, chat in
                                    
                                    ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                                        .scaleEffect(x: -1, y: 1, anchor: .center)
                                        .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})
                                        .onLongPressGesture {
                                            if !chat.isTeamSaylo {
                                                withAnimation {
                                                    MainViewModel.shared.settingsChat = chat
                                                }
                                            }
                                        }
                                }
                                
                            }
                        })
                        .padding(.horizontal, 8)
                        
                    } else {
                        
                        ScrollView {
                            
                            
                            VStack {
                                
                                LazyVGrid(columns: items, spacing: 16, content: {
                                    
                                    
                                    ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                        
                                        ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                                            .scaleEffect(x: -1, y: 1, anchor: .center)
                                            .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})
                                            .onLongPressGesture {
                                                if !chat.isTeamSaylo {
                                                    withAnimation {
                                                        MainViewModel.shared.settingsChat = chat
                                                    }
                                                }
                                            }
                                    }
                                })
                                .padding(.horizontal, 8)
                                .padding(.top, 8)
                                
                            }.background(GeometryReader {
                                Color.clear.preference(key: ViewOffsetKey.self,
                                                       value: -$0.frame(in: .named("scroll")).origin.y)
                                
                            })
                            .onPreferenceChange(ViewOffsetKey.self) {
                                
                                if $0 < -10 {
                                    
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                        }
                        .coordinateSpace(name: "scroll")
                        
                    }
                    
                    Spacer()
                    
                }
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .padding(.top, 14)
                
                
                VStack {
                    Rectangle()
                        .foregroundColor(Color(.systemGray))
                        .frame(width: IS_SMALL_WIDTH ? 38 : 48, height: 4)
                        .clipShape(Capsule())
                        .padding(.top, 6)
                    
                    Spacer()
                }
            }
        }
        .frame(width: SCREEN_WIDTH, height: CHATS_VIEW_HEIGHT * 3)
        .cornerRadius(IS_SMALL_PHONE ? 12 : 20)
        .offset(dragOffset)
        .padding(.bottom, -CHATS_VIEW_HEIGHT*2)
        .gesture(
            
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { gesture in
                    let height = dragOffset.height + (gesture.translation.height - dragOffset.height)
                    dragOffset.height = min(max(height, maxHeight), 0)
                }
                .onEnded { gesture in
                    
                    withAnimation(.linear(duration: 0.2)) {
                        
                        if abs(dragOffset.height) > 200 {
                            dragOffset.height = maxHeight
                        } else {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
        
        
    }
    
    func handleTapGesture(chat: Chat) {
        
        let delay = MainViewModel.shared.selectedView == .Saylo && chat.messages.isEmpty ? 0.1 : 0.0
        
        self.conversationViewModel.index = -1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            conversationViewModel.setChat(chat: chat)
            MainViewModel.shared.reset()
        }
        
        withAnimation {
            dragOffset = .zero
        }
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

