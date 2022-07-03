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
    @State var hasJoinedCall = false
    @State var hasRejectedCall = false
    
    var cameraView = CameraView()
    let bottomPadding: CGFloat = IS_SMALL_PHONE ? 4 : 8
    
    var body: some View {
        
        ZStack {
            ZStack(alignment: .center) {
                
                Color.black.ignoresSafeArea()
                
                //The photo that was just taken
                if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                    TakenPhotoView(photo: photo)
                }
                
                LiveView(showStream: $conversationViewModel.isLive, currentlyWatchingLiveId: $conversationViewModel.currentlyWatchingId)
                
                //Camera view shown when recording video or taking photo
                if viewModel.showCamera() {
                    
                    if conversationViewModel.currentlyWatchingId == nil {
                        cameraView
                            .onTapGesture(count: 2, perform: { switchCamera() })
                            .overlay(
                                ZStack {
                                    VStack {
                                        RoundedRectangle(cornerRadius: 36)
                                            .stroke(Color.black, lineWidth: TOP_PADDING)
                                            .frame(width: SCREEN_WIDTH + TOP_PADDING,
                                                   height: MESSAGE_HEIGHT + TOP_PADDING)
                                            .padding(.top, TOP_PADDING/2)
                                        Spacer()
                                    }
                                }
                            )
                    }
                    
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
                            
                            if conversationViewModel.presentUsers.count > 1, viewModel.selectedView != .Saylo, conversationViewModel.joinedCallUsers.count == 0, !hasJoinedCall {
                                JoinCallSmallView(hasJoinedCall: $hasJoinedCall)
                            }
                            
                            ZStack {
                                
                                VideoOptionsView()
                                
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
                                                    .frame(height: 27)
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                                            }
                                            .frame(width: IS_SMALL_WIDTH ? 30 : 36, height: 27)
                                            
                                        }
                                        .padding(.horizontal, IS_SMALL_WIDTH ? 12 : 20)
                                        .frame(width: SCREEN_WIDTH)
                                        .padding(.bottom, bottomPadding + (IS_SMALL_PHONE ? 2 : 0))
                                        
                                    }
                                    
                                    if viewModel.isRecording || viewModel.selectedView == .Photo {
                                        CancelRecordingButton(bottomPadding: bottomPadding).zIndex(6)
                                    }
                                }
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
                
                if conversationViewModel.joinedCallUsers.count > 0 && !conversationViewModel.joinedCallUsers.contains(AuthViewModel.shared.getUserId()) && !hasRejectedCall {
                    JoinCallLargeView(joinedCallUsers: $conversationViewModel.joinedCallUsers, hasRejectedCall: $hasRejectedCall)
                }
                
                Group {
                    
                    if viewModel.showFindFriends {
                        ContactsView()
                            .zIndex(5)
                            .transition(.move(edge: .bottom))
                            .frame(width: SCREEN_WIDTH)
                            .cornerRadius(14)
                    }
                    
                    
                    if let chat = viewModel.settingsChat {
                        ChatSettingsView(chat: chat)
                            .zIndex(5)
                            .navigationBarHidden(true)
                            .transition(.move(edge: .bottom))
                            .cornerRadius(14)
                        
                    }
                }
                
                if let message = viewModel.selectedMessage {
                    MessageOptionsView(message: message, showAlert: $showAlert).zIndex(6)
                }
            }
            .overlay(
                
                ZStack {
                    
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
                    
                    if hasJoinedCall {
                        WaitingForUserView(chat: conversationViewModel.chat!, hasJoinedCall: $hasJoinedCall)
                    }
                }
            )
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .bottom)
            .alert(isPresented: $showAlert) {
                let messages = conversationViewModel.showSavedPosts ? conversationViewModel.savedMessages : conversationViewModel.messages
                return savedPostAlert(mesageIndex: messages.firstIndex(where: {$0.id == messages[conversationViewModel.saveToggleIndex].id}), completion: { isSaved in
                    
                })
            }
            
            //        .onAppear {
            //            cameraView.startRunning()
            //        }
            
            //        } else {
            
            if !(!conversationViewModel.joinedCallUsers.contains(AuthViewModel.shared.getUserId()) || conversationViewModel.joinedCallUsers.count < 2) || conversationViewModel.showCall {
                
                CallView()
                    .ignoresSafeArea()
                    .onAppear {
                        hasJoinedCall = false
                    }
                    .onDisappear {
                        conversationViewModel.joinedCallUsers.removeAll()
                    }
            }
            
            if viewModel.showCamera() && conversationViewModel.currentlyWatchingId == nil {
                MessageAdOnsView(selectedFilter: $conversationViewModel.selectedFilter)
            }
            
            VStack {
                Spacer()
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
            
            if viewModel.showCaption || !textOverlayViewModel.overlayText.isEmpty {
                TextOverlayView(color: $textColor)
            }
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
    
    func setFilter(_ filter: Filter?) {
        cameraView.setFilter(filter)
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
    @Binding var currentlyWatchingLiveId: String?
    
    var body: some View {
        
        ZStack {
            
            if showStream {
                LiveStreamViewRepresentable()
                    .overlay(
                        ZStack{
                            Button(action: {
                                ConversationViewModel.shared.hideLiveView()
                            }, label: {
                                VStack {
                                    HStack {
                                        XButton()
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            })
                            
                            if currentlyWatchingLiveId != nil {
                                VStack {
                                    
                                    Spacer()
                                    
                                    Text("Live")
                                        .foregroundColor(.white)
                                        .font(Font.system(size: 15, weight: .semibold, design: .rounded))
                                        .frame(width: 50, height: 24)
                                        .background(Color.mainBlue)
                                        .cornerRadius(4)
                                        .padding(.bottom, BOTTOM_PADDING + MINI_MESSAGE_HEIGHT + 20)
                                    
                                }
                            }
                        }
                        
                    )
            }
        }
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
                        
                        Spacer()
                        
                        if let chat = ConversationViewModel.shared.chat {
                            
                            Button {
                                
                                ConversationViewModel.shared.removeChat()
                                ConversationGridViewModel.shared.showConversation = false
                                
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
    
    var chat = ConversationViewModel.shared.chat
    let dimension: CGFloat = IS_SMALL_WIDTH ? 44 : (IS_SMALL_PHONE ? 46 : 48)
    @Binding var hasJoinedCall: Bool
    
    var body: some View {
        
        Button {
            withAnimation {
                hasJoinedCall = true
            }
            ConversationViewModel.shared.setIsOnCall()
        } label: {
            
            VStack(spacing: 4) {
                
                if let chat = chat {
                    ChatImageCircle(chat: chat, diameter: dimension)
                        .overlay(RoundedRectangle(cornerRadius: dimension/2)
                            .stroke(Color.white, lineWidth: 2))
                }
                //                KFImage(URL(string: imageName))
                //                    .resizable()
                //                    .scaledToFill()
                //                    .frame(width: dimension, height: dimension)
                //                    .clipShape(Circle())
                
                
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
            .padding(.bottom, 8)
            .shadow(color: Color(.init(white: 0, alpha: 0.06)), radius: 16, x: 0, y: 4)
        }
    }
}

struct JoinCallLargeView: View {
    
    var imageName = ConversationViewModel.shared.chat?.profileImage ?? ""
    @Binding var joinedCallUsers: [String]
    @Binding var hasRejectedCall: Bool
    
    let width = 265
    
    var body: some View {
        
        ZStack {
            
            Color.init(white: 0, opacity: 0.4)
            
            VStack(spacing: 24) {
                
                HStack {
                    Text(getStartedCallString())
                        .foregroundColor(.white)
                        .font(Font.system(size: 23, weight: .medium, design: .rounded))
                    Spacer()
                }
                
                
                HStack {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: -15) {
                            
                            ForEach(Array(joinedCallUsers.enumerated()), id: \.1) { i, id in
                                
                                if let chatMember = getChatMember(fromId: id) {
                                    
                                    KFImage(URL(string: chatMember.profileImage))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 46, height: 46)
                                        .clipShape(Circle())
                                        .overlay(
                                            ZStack {
                                                if i > 0 {
                                                    RoundedRectangle(cornerRadius: 23)
                                                        .stroke(Color.init(white: 0, opacity: 0.5), lineWidth: 1)
                                                }
                                            }
                                        )
                                }
                            }
                        }
                    }
                    .frame(width: 120)
                    
                    Spacer()
                    
                    JoinCallOptionsView(height: 42, hasRejectedCall: $hasRejectedCall)
                }
                
            }
            .padding(.horizontal, 14)
        }
        .frame(width: 240, height: 125)
        .cornerRadius(12)
        
    }
    
    func getStartedCallString() -> String {
        
        let joinedCallUsers = ConversationViewModel.shared.joinedCallUsers
        guard joinedCallUsers.count > 0, let chatMember = getChatMember(fromId: joinedCallUsers[0]) else { return "" }
        
        
        return chatMember.firstName + " started a call"
    }
    
    
    func getChatMember(fromId uid: String) -> ChatMember? {
        guard let chat = ConversationViewModel.shared.chat, let chatMember = chat.chatMembers.first(where: {$0.id == uid})
        else {
            return nil
        }
        
        return chatMember
    }
}

struct JoinCallOptionsView: View {
    
    let height: CGFloat
    @Binding var hasRejectedCall: Bool
    
    var body: some View {
        
        HStack {
            
            //X Button
            Button {
                withAnimation {
                    hasRejectedCall = true
                }
            } label: {
                
                ZStack {
                    
                    Color.init(white: 170/250)
                    
                    Image("x")
                        .resizable()
                        .scaledToFit()
                        .frame(width: height/2, height: height/2)
                    
                }
                .frame(width: height, height: height)
                .cornerRadius(5)
            }
            
            //Join Button
            Button {
                withAnimation {
                    ConversationViewModel.shared.setIsOnCall()
                }
            } label: {
                
                ZStack {
                    
                    Color.mainBackgroundBlue
                    
                    Text("Join")
                        .font(Font.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                }
                .frame(width: 48, height: height)
                .cornerRadius(5)
            }
        }
    }
}
