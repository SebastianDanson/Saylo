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

    
    @State var isFrontFacing = true
    @State var dragOffset: CGSize = .zero
    var cameraView = CameraView()
    
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            //video player
            if viewModel.videoUrl != nil {
                
                VStack {
                    
                    viewModel.videoPlayerView
                        .padding(.top, TOP_PADDING)
                    
                    Spacer()
                    
                }.zIndex(3)
            }
            
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
            
            //camera
            cameraView
                .onTapGesture(count: 2, perform: {
                    switchCamera()
                })
            
            
            VStack {
            NavView(searchText: $searchText)
                Spacer()
            }

            VStack(spacing: 6) {
                
                Spacer()
                
                
                ZStack {
                    
                CameraCircle()
                    .padding(.bottom, 16)
                    
                    HStack {
                        
                        Spacer()
                        
                        ZStack {
                            
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.fadedBlack)
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(Font.title.weight(.semibold))
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(.white)
                            
                        }.padding(.trailing, 24)

                        
                    }
                }
                
                MessageOptions(type: $conversationViewModel.messageType)

                    ScrollView(showsIndicators: false) {
                        
                        Color.white.ignoresSafeArea()

                        VStack {
                            
                            LazyVGrid(columns: items, spacing: 14, content: {

                                ForEach(Array(gridviewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                    
                                    ConversationGridCell(chat: $gridviewModel.chats[i])
                                        .onTapGesture(count: 1, perform: {
                                            if gridviewModel.isSelectingChats {
                                                withAnimation(.linear(duration: 0.15)) {
                                                    gridviewModel.toggleSelectedChat(chat: chat)
                                                }
                                                
                                            } else {
                                                conversationViewModel.setChat(chat: chat)
                                                gridviewModel.showConversation = true
                                            }
                                            CameraViewModel.shared.cameraView.stopRunning()
                                        })
                                }
                            })
                                .padding(.horizontal, 8)
                                .padding(.top, -8)

                        }

                    }
                    .background(Color.white)
                    .frame(width: SCREEN_WIDTH, height: 265)
                    .background(Color.white)
                    .cornerRadius(14)
            }
            
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
                
                if SCREEN_RATIO > 2 {
                    //                    VStack{
                    //                        RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                    //                            .frame(width: CAMERA_WIDTH + 20, height: CAMERA_WIDTH * 16/9 + 20)
                    //
                    //
                    //                        Spacer()
                    //                    }.padding(.top, TOP_PADDING - 10)
                    
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
                
                if viewModel.photo != nil || viewModel.videoUrl != nil {
                    
                    VStack {
                        
                        ZStack {
                            
                            
                            MediaOptions()
                                .padding(.top, TOP_PADDING)
                            
                            
                        }
                        
                    }
                }
                
            }
        )
        //        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        //        .ignoresSafeArea()
        .navigationBarHidden(true)
        .background(Color.black)
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

