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
    
    @State private var searchText = ""
    @State private var noteText = ""
    
    @State var isFrontFacing = true
    @State var isTyping = false
    
    var cameraView = CameraView()
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            //            if let chat = viewModel.chat {
            //                NavigationLink(destination: ChatSettingsView(chat: chat, showSettings: $showSettings)
            //                                .navigationBarHidden(true)
            //                               , isActive: $showSettings) { EmptyView() }
            //            }
            
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
                NoteView(noteText: $noteText, isTyping: $isTyping)
                
            }
            
            //Saylo View
            if viewModel.selectedView == .Saylo {
//                ConversationPlayerView()
            }
            
            if viewModel.showPhotos {
                PhotosView()
            }
            
            ZStack {
                //Overlay Buttons
                VStack(spacing: 6) {
                    
                    Spacer()
                    
                    ZStack {
                        
                        //Recording voice or video
                        if viewModel.showRecordButton() {
                            Button {
                                viewModel.handleRecordButtonTapped()
                            } label: {
                                RecordButton()
                            }
                        }
                        
                        //Taking Photo
                        if viewModel.selectedView == .Photo {
                            Button {
                                viewModel.handlePhotoButtonTapped()
                            } label: {
                                PhotoButton(photo: $viewModel.photo)
                            }
                        }
                        
                        //Writing Note
                        if viewModel.selectedView == .Note {
                            
                            Button {
                                ConversationViewModel.shared.sendMessage(text: noteText, type: .Text)
                                noteText = ""
                            } label: {
                                SendButton()
                            }
                        }
                        
                        
                        if viewModel.photo != nil {
                            //The Buttons on either of the photo button
                            TakenPhotoOptions()
                        } else if viewModel.showRecordButton() || viewModel.selectedView == .Photo {
                            //The Buttons on either of the record button
                            //                        PhotoLibraryAndSwitchCameraView(cameraView: cameraView)
                        }
                        
                    }.padding(.bottom, 12)
                    
                    
                    if !viewModel.isRecording && !viewModel.showPhotos {
                        //The 5 buttons that toggle the message types
                        
                        HStack {
                            
                            Button {
                                viewModel.showPhotos = true
                            } label: {
                                LastPhotoView()
                            }
                            
                            Spacer()
                            
                            MessageOptions(type: $viewModel.selectedView, isRecording: $viewModel.isRecording)
                            
                            Spacer()
                            
                            Button {
                                cameraView.switchCamera()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .resizable()
                                    .font(Font.title.weight(.semibold))
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .shadow(color: Color(white: 0, opacity: 0.4), radius: 4, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        
                    } else if viewModel.isRecording {
                        
                        Button {
                            if viewModel.selectedView == .Voice {
                                viewModel.audioRecorder.cancelRecording()
                                viewModel.cancelRecording()
                            } else {
                                viewModel.cancelRecording()
                            }
                        } label: {
                            Image("x")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .shadow(color: Color(white: 0, opacity: 0.4), radius: 4, x: 0, y: 4)
                        }
                        .frame(width: 36, height: 36)
                        .padding(.bottom, 12)
                    }
                    
                    //                ZStack {
                    
                    //                }
                }
                .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET)
                
                VStack {
                    Spacer()
                    UnreadMessagesScrollView(selectedView: $viewModel.selectedView)
                        .padding(.bottom, SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET - MINI_MESSAGE_HEIGHT - 2)
                }
                
                VStack {
                    Spacer()
                    ChatsView(selectedView: $viewModel.selectedView)
                }
                
                
            }
            .zIndex(3)
            
            if viewModel.showAddFriends {
                AddFriendsView()
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
            
            if viewModel.showFindFriends {
                ContactsView()
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
            
            if viewModel.showNewChat {
                NewConversationView()
                    .zIndex(5)
                    .transition(.move(edge: .bottom))
            }
            
            
        }
        .overlay(
            ZStack {
                
                
                //NavView
                if !viewModel.isRecording && viewModel.selectedView != .Saylo && !viewModel.showNewChat && !viewModel.isCalling && !viewModel.showAddFriends {
                    
                    VStack {
                        NavView(searchText: $searchText)
                        Spacer()
                    }
                } else if viewModel.isRecording {
                    VStack {
                        RecordTimerView()
                            .padding(.top, TOP_PADDING_OFFSET + 8)
                        Spacer()
                    }
                }
                
                //Camera Flash View
                if viewModel.isRecording && isFrontFacing && viewModel.hasFlash {
                    FlashView().zIndex(4)
                }
            }
        )
        .navigationBarHidden(true)
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            cameraView.startRunning()
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

struct TakenPhotoView: View {
    
    var photo: UIImage
    
    var body: some View {
        
        VStack {
            
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: CAMERA_WIDTH, height: MESSAGE_HEIGHT)
                .cornerRadius(20)
                .padding(.top, TOP_PADDING_OFFSET)
            
            Spacer()
            
        }.zIndex(3)
    }
}

struct VoiceView: View {
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image(systemName: "mic.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.white)
            
            
            Spacer()
            Spacer()
            
        }
        .frame(width: SCREEN_WIDTH)
        .background(Color.alternateMainBlue)
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
            
        }
        
    }
}


struct NoteView: View {
    
    @Binding var noteText: String
    @Binding var isTyping: Bool
    
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                if !isTyping && noteText.isEmpty {
                    
                    Text("Tap to type")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                MultilineTextField(text: $noteText, height: MESSAGE_HEIGHT)
                    .frame(width: SCREEN_WIDTH - 40)
                    .onTapGesture {
                        isTyping = true
                    }
            }
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(width: SCREEN_WIDTH)
        .background(Color.alternateMainBlue)
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


//Chats scroll view at bottom of screen
struct ChatsView: View {
    
    private let items = [GridItem(), GridItem(), GridItem(), GridItem()]
    
    @StateObject var conversationViewModel = ConversationViewModel.shared
    @StateObject private var gridviewModel = ConversationGridViewModel.shared
    @Binding var selectedView: MainViewType
    @State var dragOffset: CGSize = .zero

    let maxHeight = -CHATS_VIEW_HEIGHT * 2 - 4
    let backgroundColor = Color(red: 48/255, green: 54/255, blue: 64/255)
    
    var body: some View {
        
        ZStack {
            
            backgroundColor.ignoresSafeArea()
            
            VStack {
                
                if dragOffset == .zero {
                    
                    LazyVGrid(columns: items, spacing: 0, content: {
                        
                        if gridviewModel.chats.count > 0 {
                            
                            ForEach(Array(gridviewModel.chats[0...min(gridviewModel.chats.count, 3)].enumerated()), id: \.1.id) { i, chat in
                                
                                ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                                    .scaleEffect(x: -1, y: 1, anchor: .center)
                                    .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})

                            }
                        }
                    })
                    .padding(.horizontal, 8)
                    
                } else {
                    
                    ScrollView {
                        
                        
                        VStack {
                            LazyVGrid(columns: items, spacing: 12, content: {
                                
                                
                                ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                    
                                    ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                                        .scaleEffect(x: -1, y: 1, anchor: .center)
                                        .onTapGesture(count: 1, perform: { handleTapGesture(chat: chat)})
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
                    .frame(width: 48, height: 4)
                    .clipShape(Capsule())
                    .padding(.top, 6)
                
                Spacer()
            }
            
        }
        .frame(width: SCREEN_WIDTH, height: CHATS_VIEW_HEIGHT * 3)
        .cornerRadius(20)
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
        
            conversationViewModel.setChat(chat: chat)
            selectedView = .Saylo
            MainViewModel.shared.reset()
            
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
