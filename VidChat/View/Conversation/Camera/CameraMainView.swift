//
//  CameraMainView.swift
//  Saylo
//
//  Created by Student on 2021-09-27.
//

import SwiftUI
import Kingfisher
import AVFoundation

struct CameraMainView: View {
    
    private let items = [GridItem(), GridItem(), GridItem()]
    
    @StateObject var viewModel = CameraViewModel.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared
    @StateObject private var gridviewModel = ConversationGridViewModel.shared
    
    @State private var searchText = ""
    @State private var noteText = ""
    
    @State var isFrontFacing = true
    @State var dragOffset: CGSize = .zero
    
    var cameraView = CameraView()
    
    
    var body: some View {
        
        let textView = MultilineTextField(text: $noteText, height: SCREEN_WIDTH * 1.5) {
            
        }
        
        ZStack(alignment: .center) {
            
            //video player
            //            if viewModel.videoUrl != nil {
            //
            //                VStack {
            //
            //                    viewModel.videoPlayerView
            //                        .padding(.top, TOP_PADDING - 12)
            //
            //                    Spacer()
            //
            //                }.zIndex(2)
            //            }
            
            if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                
                VStack {
                    
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: CAMERA_WIDTH, height: CAMERA_WIDTH * 16/9)
                        .cornerRadius(20)
                        .padding(.top, TOP_PADDING)
                    
                    Spacer()
                    
                }.zIndex(3)
            }
            
            if conversationViewModel.messageType == .Video  || conversationViewModel.messageType == .Photo {
                //camera
                cameraView
                    .onTapGesture(count: 2, perform: {
                        switchCamera()
                    })
                
            } else if conversationViewModel.messageType == .Voice {
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
                
            } else if conversationViewModel.messageType == .Note {
                      
                VStack {
                ZStack {
                    
                   
                    
                    if !conversationViewModel.isTyping && noteText.isEmpty {
                        Text("Tap to type")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            
                    }
                    
                    textView
                        .frame(width: SCREEN_WIDTH - 40)
                        .onTapGesture {
                            conversationViewModel.isTyping = true
                        }
                }
                    Spacer()
                }
                .ignoresSafeArea(edges: .bottom)
                .frame(width: SCREEN_WIDTH)
                .background(Color.alternateMainBlue)
                
            } else if conversationViewModel.messageType == .Saylo {
                ConversationView()
            }
            
            
            VStack(spacing: 6) {
                
                Spacer()
                
                ZStack {
                    
                    if conversationViewModel.messageType == .Video || conversationViewModel.messageType == .Photo || conversationViewModel.messageType == .Voice {
                        
                        
                        //Voice and Video button
                        Button {
                            withAnimation {
                                
                                if conversationViewModel.messageType == .Video {
                                    viewModel.handleTap()
                                } else if conversationViewModel.messageType == .Voice {
                                    viewModel.handleAudioTap()
                                }
                            }
                        } label: {
                            ZStack {
                                
                                CameraCircle()
                                
                                if conversationViewModel.messageType == .Photo {
                                    Circle()
                                        .frame(width: 45, height: 45)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        
                        //Camera button
                        
                        Button {
                            if viewModel.photo == nil {
                                viewModel.takePhoto()
                            } else {
                                viewModel.sendPhoto()
                            }
                        } label: {
                            
                            ZStack {
                                
                                Circle()
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                    .frame(width: 62, height: 62)
                                
                                Circle()
                                    .frame(width: 56, height: 56)
                                    .foregroundColor(.white)
                                
                            }
                           
                        }

                        
                        HStack {
                            
                            if !viewModel.isRecording {
                                
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.white)
                            } else {
                                
                                Button {
                                    
                                    viewModel.cancelRecording()
                                    
                                } label: {
                                        
                                        Image("x")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 28, height: 28)
                                            .padding()
                                        
                                }
                                
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .font(Font.title.weight(.semibold))
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            
                        }.frame(width: 240)
                    } else if conversationViewModel.messageType == .Note {
                        
                        Button {
                            conversationViewModel.sendMessage(text: noteText, type: .Text)
                            noteText = ""
                        } label: {
                            
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
         
                }.padding(.bottom, 8)
                
                
                MessageOptions(type: $conversationViewModel.messageType, isRecording: $viewModel.isRecording)
                    .frame(height: 24)
                    
                
                ScrollView(showsIndicators: false) {
                    
                 Color.white.ignoresSafeArea()
                    
                    
                    VStack {
                        
                        LazyVGrid(columns: items, spacing: 12, content: {
                            
                            ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                
                                ConversationGridCell(chat: $gridviewModel.chats[i], selectedChatId: $conversationViewModel.chatId)
                                    .scaleEffect(x: -1, y: 1, anchor: .center)
                                    .onTapGesture(count: 1, perform: {
                                        //                                        if gridviewModel.isSelectingChats {
                                        //                                            withAnimation(.linear(duration: 0.15)) {
                                        //                                                gridviewModel.toggleSelectedChat(chat: chat)
                                        //                                            }
                                        //
                                        //                                        } else {
                                        conversationViewModel.setChat(chat: chat)
//                                        gridviewModel.showConversation = true
                                        //                                        }
                                        //                                        CameraViewModel.shared.cameraView.stopRunning()
                                    })
                            }
                        })
                            .padding(.horizontal, 8)
                            .padding(.top, -8)
                        
                    }
                    .scaleEffect(x: -1, y: 1, anchor: .center)

                }
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT - SCREEN_WIDTH * 1.5 - TOP_PADDING + 22)
                .ignoresSafeArea(edges: .bottom)
                .background(Color.white)
                .cornerRadius(14)
            }
            .zIndex(3)
            
        }
        .gesture(ConversationGridViewModel.shared.hasUnreadMessages ? nil :
                    
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { gesture in
            dragOffset.height = max(0, gesture.translation.height)
        }
                    .onEnded { gesture in
            
            withAnimation(.linear(duration: 0.2)) {
                
                if dragOffset.height > SCREEN_HEIGHT / 4 {
                    
                    ConversationViewModel.shared.showCamera = false
                    viewModel.isShowingPhotoCamera = false
                    viewModel.isRecording = false
                    //                            if !viewModel.isShowingPhotoCamera {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.reset(hideCamera: true)
                    }
                    //                            }
                    
                } else {
                    dragOffset.height = 0
                }
            }
        }
        )
        .overlay(
            ZStack {
                
                if !viewModel.isRecording {
                    VStack {
                        NavView(searchText: $searchText)
                        Spacer()
                    }

                }
                
                if (viewModel.isRecording || viewModel.isTakingPhoto) && isFrontFacing && viewModel.hasFlash {
                    FlashView().zIndex(4)
                }
                
                if AuthViewModel.shared.hasCompletedSignUp &&
                    ((ConversationGridViewModel.shared.hasUnreadMessages && viewModel.showFullCameraView)
                     || !ConversationGridViewModel.shared.hasUnreadMessages) {
                    
                    //Will show these options unless taking profile picture
                    if conversationViewModel.showCamera {
                        CameraOptions(isFrontFacing: $isFrontFacing, cameraView: cameraView).padding(.horizontal, 0).zIndex(6)
                    }
                }
                
                //                if viewModel.photo != nil || viewModel.videoUrl != nil {
                //
                //                    VStack {
                //
                //                        ZStack {
                //
                //
                //                            MediaOptions()
                //                                .padding(.top, TOP_PADDING)
                //
                //
                //                        }
                //
                //                    }
                //                }
                
            }
                .ignoresSafeArea(edges: .bottom)
        )
        //        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        //        .ignoresSafeArea()
        .navigationBarHidden(true)
        .background(Color.black)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            cameraView.startRunning()
        }
        
    }
    
    func setPreviewLayerFullFrame() {
        cameraView.setPreviewlayerFullFrame()
    }
    
    func setPreviewLayerSmallFrame() {
        cameraView.setPreviewlayerSmallFrame()
    }
    
    func switchCamera() {
        cameraView.switchCamera()
    }
    
    func startRecording() {
        cameraView.startRecording()
    }
    
    func stopRecording() {
        cameraView.stopRecording()
    }
    
    func addAudio() {
        //        cameraView.addAudio()
    }
    
    func cancelRecording() {
        cameraView.cancelRecording()
    }
    
    func takePhoto() {
        CameraViewModel.shared.isTakingPhoto = true
        let hasFlash = CameraViewModel.shared.hasFlash
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
    
    func setupWriter() {
        //        cameraView.setupWriter()
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

