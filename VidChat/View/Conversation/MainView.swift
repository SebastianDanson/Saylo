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
    @StateObject var textOverlayViewModel = TextOverlayViewModel.shared

    @State private var searchText = ""
    @State private var noteText = ""
    @State var isTyping = false
    @State var showAllowAudioAlert = false
    @State var showAllowCameraAccessAlert = false
    @State var showAlert = false
    @State var textColor: Color = .white
    
    var cameraView = CameraView()
    let bottomPadding: CGFloat = IS_SMALL_PHONE ? 4 : 8
    
    var body: some View {
        
        if !conversationViewModel.joinedCallUsers.contains(AuthViewModel.shared.getUserId()) {
            
            
            ZStack(alignment: .center) {
                
                Color.black.ignoresSafeArea()
                
                //The photo that was just taken
                if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                    TakenPhotoView(photo: photo)
                }
                
                //
                //            if conversationViewModel.isLive {
                //
                //
                //            }
                LiveView(showStream: $conversationViewModel.isLive)
                
                //Camera view shown when recording video or taking photo
                if viewModel.showCamera() {
                    
                    if conversationViewModel.currentlyWatchingId == nil {
                        cameraView
                            .onTapGesture(count: 2, perform: { switchCamera() })
                    }
                    
                }
                
                if viewModel.showCaption || !textOverlayViewModel.overlayText.isEmpty {
                    TextOverlayView(color: $textColor)
                }
                
                
                // Voice view
                Group {
                    
                    if viewModel.selectedView == .Voice {
                        VoiceView()
                    }
                    
                    //Note View
                    if viewModel.selectedView == .Note {
                        NoteView(noteText: $noteText)
                    }
                    
                    //Saylo View
                    if viewModel.selectedView == .Saylo {
                        ConversationPlayerView(showAlert: $showAlert)
                    }
                    
                    if viewModel.showPhotos {
                        PhotosView()
                    }
                }
                
                ZStack {
                    
                    VStack {
                        Spacer()
                        
                        if !viewModel.showFilters && !viewModel.showCaption {
                            UnreadMessagesScrollView(selectedView: $viewModel.selectedView, showAlert: $showAlert)
                                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET - MINI_MESSAGE_HEIGHT - (IS_SMALL_WIDTH ? 3 : 4))
                        }
                        
                        if viewModel.showCaption {
                            TextColorView(selectedColor: $textColor)
                                .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET - MINI_MESSAGE_HEIGHT - (IS_SMALL_WIDTH ? 3 : 4))
                        }
                        
                        if viewModel.showFilters {
                            FiltersView()
                                .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET - MINI_MESSAGE_HEIGHT - (IS_SMALL_WIDTH ? 3 : 4))
                        }
                        
                    }
                    
                    //Camera Flash View
                    if viewModel.isRecording && viewModel.isFrontFacing && viewModel.hasFlash {
                        FlashView().zIndex(2)
                    }
                    
                    if conversationViewModel.currentlyWatchingId == nil {
                        //Overlay Buttons
                        VStack(spacing: 6) {
                            
                            
                            Spacer()
                            
                            //Add message in chat for calls
                            
                            if conversationViewModel.presentUsers.count > 1, viewModel.selectedView != .Saylo, conversationViewModel.joinedCallUsers.count == 0 {
                                JoinCallSmallView()
                            }
                            
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
                                            if viewModel.isRecording && viewModel.selectedView != .Voice {
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
                                    .overlay(
                                        ZStack {
                                            
                                            if viewModel.photo == nil {
                                                SwitchCameraView()
                                            }
                                        }
                                    )
                                }
                                
                                
                                if viewModel.photo != nil {
                                    //The Buttons on either of the photo button
                                    TakenPhotoOptions()
                                }
                                
                            }.padding(.bottom, bottomPadding)
                            
                            
                            VStack(spacing: 0) {
                                
                                ZStack {
                                    
                                    if !viewModel.isRecording && !viewModel.showPhotos && viewModel.selectedView != .Saylo && viewModel.selectedView != .Photo {
                                        
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
                                        CancelRecordingButton(bottomPadding: bottomPadding).zIndex(6)
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
                        
                    }
                    
                    if !viewModel.isRecording && viewModel.selectedView != .Note && conversationViewModel.currentlyWatchingId == nil {
                        ChatNavView(selectedView: $viewModel.selectedView, presentUsers: $conversationViewModel.presentUsers)
                    }
                }
                .zIndex(3)
                
                if conversationViewModel.joinedCallUsers.count > 0 {
                    JoinCallLargeView()
                }
                
                Group {
                    
                    if viewModel.showFindFriends {
                        ContactsView()
                            .zIndex(5)
                            .transition(.move(edge: .bottom))
                            .frame(width: SCREEN_WIDTH)
                            .cornerRadius(14)
                    }
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
                            .navigationBarHidden(true)
                            .transition(.move(edge: .bottom))
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
                }
                
                if let message = viewModel.selectedMessage {
                    MessageOptionsView(message: message).zIndex(6)
                }
            }
            .overlay(
                
                ZStack {
                    
                    MessageAdOnsView(selectedFilter: $conversationViewModel.selectedFilter)
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
                    
                    if viewModel.isSaving {
                        SavedPopUp()
                            .padding(.bottom, MINI_MESSAGE_HEIGHT)
                    }
                    
                }
            )
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .bottom)
            .alert(isPresented: $showAlert) {
                savedPostAlert(mesageIndex: conversationViewModel.messages.firstIndex(where: {$0.id == conversationViewModel.messages[conversationViewModel.index].id}), completion: { isSaved in
                    
                })
            }
            
            //        .onAppear {
            //            cameraView.startRunning()
            //        }
            
        } else {
            CallView().ignoresSafeArea()
        }
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

struct LiveView: View {
    
    @Binding var showStream: Bool
    
    var body: some View {
        
        ZStack {
            
            if showStream {
                LiveStreamViewRepresentable()
                    .overlay(
                        Button(action: {
                            ConversationViewModel.shared.hideLiveView()
                        }, label: {
                            XButton()
                        })
                        , alignment: .topLeading
                    )
            }
        }
        
        //TOdo is talking notification only the first time so if they cancel recording and strat again it doesn't send another notification
        
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

struct ChatNavView: View {
    
    @Binding var selectedView: MainViewType
    @Binding var presentUsers: [String]
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                HStack {
                    
                    let circleDimension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 32 : 35) : 39
                    
                    if selectedView != .Saylo {
                        
                        Button {
                            ConversationViewModel.shared.removeChat()
                            ConversationGridViewModel.shared.showConversation = false
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .foregroundColor(.fadedBlack)
                                    .frame(width: circleDimension, height: circleDimension)
                                
                                let xDimension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 16 : 18) : 20
                                
                                Image("x")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: xDimension, height: xDimension)
                                
                            }
                        }
                        //                                .frame(width: IS_SMALL_WIDTH ? 30 : 34, height: IS_SMALL_WIDTH ? 30 : 34)
                        
                        
                        Spacer()
                        
                        
                        if let chat = ConversationViewModel.shared.chat {
                            
                            
                            Button {
                                withAnimation {
                                    MakeCallViewModel.shared.createNewOutgoingCall(toChat: chat)
                                }
                            } label: {
                                
                                ZStack {
                                    
                                    Circle()
                                        .foregroundColor(.fadedBlack)
                                        .frame(width: circleDimension, height: circleDimension)
                                    
                                    let phoneDemension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 16 : 18) : 20
                                    Image(systemName: "phone.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: phoneDemension, height: phoneDemension)
                                        .foregroundColor(.white)
                                    
                                }
                            }
                            
                            if !chat.isTeamSaylo {
                                
                                Button {
                                    withAnimation {
                                        MainViewModel.shared.settingsChat = chat
                                    }
                                } label: {
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .foregroundColor(.fadedBlack)
                                            .frame(width: circleDimension, height: circleDimension)
                                        
                                        let chatOptionsDimension: CGFloat = IS_SMALL_WIDTH ? (IS_SE ? 22 : 24) : 26
                                        
                                        Image("ChatOptions")
                                            .resizable()
                                            .renderingMode(.template)
                                            .scaledToFit()
                                            .frame(width: chatOptionsDimension, height: chatOptionsDimension)
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(90))
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        
                        Text(ConversationViewModel.shared.chat?.name ?? "")
                            .font(Font.system(size: IS_SMALL_WIDTH ? (IS_SE ? 18 : 20) : 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color(white: 0, opacity: 0.15), radius: 4, x: 0, y: 4)
                        
                        //Todo show all profile images for group members who are there and in the join call view say all the names of ppl who joined the group
                        
                        if presentUsers.count > 1 {
                            
                            
                            HStack {
                                
                                HStack(spacing: 4) {
                                    
                                    ForEach(Array(presentUsers.enumerated()), id: \.1) { i, id in
                                        
                                        if id != AuthViewModel.shared.getUserId() {
                                            KFImage(URL(string: ConversationViewModel.shared.getUserProfileImageFromId(id)))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 24, height: 24)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                
                                Text("\(presentUsers.count > 2 ? "are" : "is") here")
                                    .font(Font.system(size: IS_SMALL_WIDTH ? (IS_SE ? 14 : 15) : 17, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color(white: 0, opacity: 0.15), radius: 4, x: 0, y: 4)
                            
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 12)
        .padding(.top, TOP_PADDING + 12)
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
                .alert(isPresented: $viewModel.showPhotosAlert) {
                    if showPhotoPickerAlert {
                        return videoTooLongAlert()
                    } else {
                        return allowPhotosAlert()
                    }
                }
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
                
                
                MultilineTextField(text: $noteText, height: MESSAGE_HEIGHT, fontSize: 28, returnKey: .send)
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
                                .padding(.top, TOP_PADDING + 48 + (IS_SMALL_PHONE ? 50 : 0))
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
        .padding(.bottom, bottomPadding + (IS_SMALL_PHONE && viewModel.isRecording ? (IS_SE ? 36 : 24) : 0))
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        
    }
}

//Chats scroll view at bottom of screen
//struct ChatsView: View {
//
//    private let items = [GridItem(), GridItem(), GridItem(), GridItem()]
//
//    @StateObject var conversationViewModel = ConversationViewModel.shared
//    @StateObject private var gridviewModel = ConversationGridViewModel.shared
//    @Binding var selectedView: MainViewType
//    @Binding var dragOffset: CGSize
//
//    let maxHeight = -CHATS_VIEW_HEIGHT * 2 - 4
//    let backgroundColor = Color(red: 48/255, green: 54/255, blue: 64/255)
//
//    var body: some View {
//
//        ZStack {
//
//            if !conversationViewModel.showSavedPosts {
//
//                backgroundColor.ignoresSafeArea()
//
//
//                VStack {
//
//                    if dragOffset == .zero {
//
//                        LazyVGrid(columns: items, spacing: 0, content: {
//
//                            if gridviewModel.chats.count > 0 {
//
//                                ForEach(Array(gridviewModel.chats[0...min(gridviewModel.chats.count - 1, 3)].enumerated()), id: \.1.id) { i, chat in
//
//                                    ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
//                                        .scaleEffect(x: -1, y: 1, anchor: .center)
//                                        .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})
//                                        .onLongPressGesture {
//                                            if !chat.isTeamSaylo {
//                                                withAnimation {
//                                                    MainViewModel.shared.settingsChat = chat
//                                                }
//                                            }
//                                        }
//                                }
//
//                            }
//                        })
//                        .padding(.horizontal, 8)
//
//                    } else {
//
//                        ScrollView {
//
//
//                            VStack {
//
//                                LazyVGrid(columns: items, spacing: 16, content: {
//
//
//                                    ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
//
//                                        ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
//                                            .scaleEffect(x: -1, y: 1, anchor: .center)
//                                            .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})
//                                            .onLongPressGesture {
//                                                if !chat.isTeamSaylo {
//                                                    withAnimation {
//                                                        MainViewModel.shared.settingsChat = chat
//                                                    }
//                                                }
//                                            }
//                                    }
//                                })
//                                .padding(.horizontal, 8)
//                                .padding(.top, 8)
//
//                            }.background(GeometryReader {
//                                Color.clear.preference(key: ViewOffsetKey.self,
//                                                       value: -$0.frame(in: .named("scroll")).origin.y)
//
//                            })
//                            .onPreferenceChange(ViewOffsetKey.self) {
//
//                                if $0 < -10 {
//
//                                    withAnimation {
//                                        dragOffset = .zero
//                                    }
//                                }
//                            }
//                        }
//                        .coordinateSpace(name: "scroll")
//
//                    }
//
//                    Spacer()
//
//                }
//                .scaleEffect(x: -1, y: 1, anchor: .center)
//                .padding(.top, 14)
//
//
//                VStack {
//                    Rectangle()
//                        .foregroundColor(Color(.systemGray))
//                        .frame(width: IS_SMALL_WIDTH ? 38 : 48, height: 4)
//                        .clipShape(Capsule())
//                        .padding(.top, 6)
//
//                    Spacer()
//                }
//            }
//        }
//        .frame(width: SCREEN_WIDTH, height: CHATS_VIEW_HEIGHT * 3)
//        .cornerRadius(IS_SMALL_PHONE ? 12 : 20)
//        .offset(dragOffset)
//        .padding(.bottom, -CHATS_VIEW_HEIGHT*2)
//        .gesture(
//
//            DragGesture(minimumDistance: 0, coordinateSpace: .global)
//                .onChanged { gesture in
//                    let height = dragOffset.height + (gesture.translation.height - dragOffset.height)
//                    dragOffset.height = min(max(height, maxHeight), 0)
//                }
//                .onEnded { gesture in
//
//                    withAnimation(.linear(duration: 0.2)) {
//
//                        if abs(dragOffset.height) > 200 {
//                            dragOffset.height = maxHeight
//                        } else {
//                            dragOffset = .zero
//                        }
//                    }
//                }
//        )
//        .ignoresSafeArea(edges: .bottom)
//
//
//    }

//    func handleTapGesture(chat: Chat) {
//
//        let delay = MainViewModel.shared.selectedView == .Saylo && chat.messages.isEmpty ? 0.1 : 0.0
//
//        self.conversationViewModel.index = -1
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            conversationViewModel.setChat(chat: chat)
//            MainViewModel.shared.reset()
//        }
//
//        withAnimation {
//            dragOffset = .zero
//        }
//    }
//}


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

struct JoinCallSmallView: View {
    
    var imageName = ConversationViewModel.shared.chat?.profileImage ?? ""
    let dimension: CGFloat = IS_SMALL_WIDTH ? 44 : (IS_SMALL_PHONE ? 46 : 48)
    
    var body: some View {
        
        Button {
            ConversationViewModel.shared.setIsOnCall()
        } label: {
            
            VStack(spacing: 4) {
                
                //TODO saylo is sometime slow on iphone 7 see why and optimize where needed
                
                KFImage(URL(string: imageName))
                    .resizable()
                    .scaledToFill()
                    .frame(width: dimension, height: dimension)
                    .clipShape(Circle())
                    .overlay(RoundedRectangle(cornerRadius: dimension/2)
                        .stroke(Color.white, lineWidth: 2))
                
                HStack(spacing: 4) {
                    
                    Text("Join")
                        .foregroundColor(.white)
                        .font(Font.system(size: 13, weight: .semibold, design: .rounded))
                    
                    Image("video")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: dimension/4, height: dimension/4)
                    
                }
            }
            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
            .padding(.bottom, 8)
        }
    }
}

struct JoinCallLargeView: View {
    
    var imageName = ConversationViewModel.shared.chat?.profileImage ?? ""
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 12) {
                
                KFImage(URL(string: imageName))
                    .resizable()
                    .scaledToFill()
                    .frame(width: SCREEN_WIDTH/4, height: SCREEN_WIDTH/4)
                    .clipShape(Circle())
                    .overlay(RoundedRectangle(cornerRadius: SCREEN_WIDTH/8)
                        .stroke(Color.white, lineWidth: 4))
                
                
                Text(getJoinedCallString())
                    .foregroundColor(.white)
                    .font(Font.system(size: 22, weight: .semibold, design: .rounded))
                
                HStack(spacing: 20) {
                    
                    Button {
                        if ConversationViewModel.shared.joinedCallUsers.count < 2 {
                            //when user is removed send show them a message saying that u didn't wanna join the call
                            ConversationViewModel.shared.removeAllUsersFromCall()
                        }
                    } label: {
                        
                        ZStack {
                            
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(white: 0.73))
                            
                            Image("x")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                        }
                    }
                    
                    Button {
                        ConversationViewModel.shared.setIsOnCall()
                    } label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.alternateMainBlue)
                            
                            Image("video")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .padding(.leading, 1)
                        }
                    }
                }
            }
            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
            .padding(.bottom, MINI_MESSAGE_HEIGHT)
        }
    }
    
    func getJoinedCallString() -> String {
        
        var joinedCallString = ""
        
        guard let chat = ConversationViewModel.shared.chat else { return "" }
        
        
        ConversationViewModel.shared.joinedCallUsers.forEach { uid in
            if let chatMember = chat.chatMembers.first(where: {$0.id == uid }) {
                joinedCallString.append(joinedCallString.isEmpty ? "" : ","  + chatMember.firstName)
            }
        }
        
        return joinedCallString + " joined the call"
    }
    
}
