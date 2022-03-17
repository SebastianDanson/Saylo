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
                ConversationPlayerView()
            }
            
            if viewModel.showPhotos {
                PhotosView()
            }
            
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
                        PhotoLibraryAndSwitchCameraView(cameraView: cameraView)
                    }
                    
                }.padding(.bottom, 8)
                
                
                if !viewModel.isRecording && !viewModel.showPhotos {
                    //The 5 buttons that toggle the message types
                    MessageOptions(type: $viewModel.selectedView, isRecording: $viewModel.isRecording)
                        .frame(height: 24)
                }
                
                ChatsView(selectedView: $viewModel.selectedView)
                
            }
            .zIndex(3)
            
        }
        .overlay(
            ZStack {
                
                
                //NavView
                if !viewModel.isRecording && viewModel.selectedView != .Saylo {
                    
                    VStack {
                        NavView(searchText: $searchText)
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
    
    private let items = [GridItem(), GridItem(), GridItem()]
    
    @StateObject var conversationViewModel = ConversationViewModel.shared
    @StateObject private var gridviewModel = ConversationGridViewModel.shared
    @Binding var selectedView: MainViewType
    
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            Color.white.ignoresSafeArea()
            
            
            VStack {
                
                LazyVGrid(columns: items, spacing: 12, content: {
                    
                    ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
                        
                        ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                            .onTapGesture(count: 1, perform: {
                                conversationViewModel.setChat(chat: chat)
                                MainViewModel.shared.reset()
                            })
                    }
                })
                    .padding(.horizontal, 8)
                    .padding(.top, -8)
                
            }
            .scaleEffect(x: -1, y: 1, anchor: .center)
            
        }
        .frame(width: SCREEN_WIDTH, height: selectedView == .Saylo ? CHATS_VIEW_SMALL_HEIGHT : CHATS_VIEW_HEIGHT)
        .ignoresSafeArea(edges: .bottom)
        .background(Color.white)
        .cornerRadius(14)
    }
    
}
