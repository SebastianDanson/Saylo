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
    
    @StateObject var viewModel = CameraViewModel.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared

    @State var isFrontFacing = true
    @State var dragOffset: CGSize = .zero
    var cameraView = CameraView()
 
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            //video player
            if viewModel.videoUrl != nil {
                
                VStack {
                    
                    viewModel.videoPlayerView
                        .background(Color.clear)
                        .padding(.top, TOP_PADDING)
//                        .onAppear {
//                            print("ON APPEAR")
//                        }
                    //
                    Spacer()
                    
                }.zIndex(3)
            }
            
            if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                
                VStack{
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
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                .onTapGesture(count: 2, perform: {
                    switchCamera()
                })
            
            
            
            
            //flash view if there's front facing flash
            
            
            //            ZStack(alignment: .top) {
            
            
            //            }
        }
        .gesture(
            
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
                
                if AuthViewModel.shared.hasCompletedSignUp {
                    CameraOptions(isFrontFacing: $isFrontFacing, cameraView: cameraView).padding(.horizontal, 0).zIndex(6)
                }
                
                if viewModel.photo != nil || viewModel.videoUrl != nil {
                    
                    VStack {
                        
                        ZStack {
                        MediaOptions()
                            .padding(.top, TOP_PADDING)
                            
                            VStack {
                                
                                Spacer()
                                
                                if conversationViewModel.chat == nil {
                                    SuggestedChatsView(chats: ConversationGridViewModel.shared.chats)
                                        .padding(.bottom, BOTTOM_PADDING + 16 + 60)
                                }
                              
                            }
                        }
                        
                    }
                }
              
            }
        )
//        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//        .ignoresSafeArea()
        .background(Color(white: 0, opacity: 1))
        .navigationBarHidden(true)
        .offset(dragOffset)
        
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

struct MediaOptions: View {
    
    @StateObject var viewModel = CameraViewModel.shared
    @State var hasSaved = false
    
    var body: some View {
        
        VStack {
            if viewModel.videoUrl != nil || viewModel.photo != nil {
                
                HStack {
                    
                    // X button
                    Button {
                        //  withAnimation(.linear(duration: 0.15)) {
                        viewModel.reset()
                        //}
                    } label: {
                        CameraOptionView(image: Image("x"), imageDimension: 14, circleDimension: 32)
                            .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    
                    Button {
                        
                        if !hasSaved {
                            if let url = viewModel.videoUrl {
                                viewModel.saveToPhotos(url: url)
                                withAnimation { hasSaved = true }
                            } else if let photo = viewModel.photo {
                                viewModel.saveToPhotos(photo: photo)
                                withAnimation { hasSaved = true }
                            }
                        }
                        
                    } label: {
                        
                        ZStack {
                        
                        Image(systemName: hasSaved ? "checkmark" : "square.and.arrow.down")
                            .resizable()
                            .font(Font.title.weight(.semibold))
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: hasSaved ? 20 : 24, height: hasSaved ? 20 : 24)
                        }
                        .frame(width: 64, height: 38)
                        .background(Color(.systemGray))
                        .clipShape(Capsule())
                   
                    }
                    .disabled(hasSaved)
                    .padding(.leading, 12)

                    if viewModel.videoUrl != nil {
                        
                        Button {
                            
                            viewModel.videoPlayerView = nil
                            viewModel.videoUrl = nil
                            viewModel.progress = 0.0
                            viewModel.isRecording = false
                            viewModel.handleTap()
                            
                        } label: {
                            
                            ZStack {
                             
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .font(Font.title.weight(.semibold))
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                
                            }
                            .frame(width: 64, height: 38)
                            .background(Color.mainBlue)
                            .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    SendButton()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, BOTTOM_PADDING + 16)
            }
        }
    }
}

struct SendButton: View {
    
    var viewModel = CameraViewModel.shared
    
    var body: some View {
        
        Button(action: {
            
            withAnimation(.linear(duration: 0.2)) {
                
                let conversationVM = ConversationViewModel.shared
                viewModel.videoPlayerView?.player.pause()
                
                if conversationVM.chatId.isEmpty {
                    withAnimation {
                        ConversationGridViewModel.shared.isSelectingChats = true
                        ConversationGridViewModel.shared.cameraViewZIndex = 1
                    }
                } else if let chat = conversationVM.selectedChat {
                    
                    conversationVM.sendCameraMessage(chatId: chat.id, chat: chat)
                    viewModel.reset(hideCamera: true)
                } else if let chat = conversationVM.chat {
                    conversationVM.isSending = true
                    conversationVM.sendCameraMessage(chatId: chat.id, chat: chat)
                    viewModel.reset(hideCamera: true)
                }
                
//                if let chat = conversationVM.selectedChat {
//                    ConversationService.updateLastVisited(forChat: chat)
//                }
            }
            
        }, label: {
            
            
            HStack(spacing: 8) {
                
                Text(getSendText())
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .semibold))
                
                Image(systemName: "location.north.fill")
                    .resizable()
                    .rotationEffect(Angle(degrees: 90))
                    .foregroundColor(.black)
                    .frame(width: 18, height: 18)
                    .scaledToFit()
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.mainBlue)
            .clipShape(Capsule())
            
            
        })
    }
    
    func getSendText() -> String {
        let viewModel = ConversationViewModel.shared
        
        if let chat = viewModel.selectedChat{
            return chat.name
        } else if viewModel.chatId == "" {
            return "See all"
        } else {
            return "Send"
        }
    }
}

struct CameraOptions: View {
    
    @StateObject var viewModel = CameraViewModel.shared
    @Binding var isFrontFacing: Bool
    
    //height of extra space above and below camera
    let nonCameraHeight = SCREEN_HEIGHT - (SCREEN_WIDTH * 16/9) // Camera aspect ratio is 16/9
    
    var cameraView: CameraView
    
    var body: some View {
        
        VStack {
            
            if viewModel.videoUrl == nil && viewModel.photo == nil {
                
                HStack {
                    
                    // X button
                    
                    Button {
                        //  withAnimation {
                        viewModel.reset()
                        cameraView.cancelRecording()
                        //}
                    } label: {
                        CameraOptionView(image: Image("x"), imageDimension: 14)
                    }
                    
                    Spacer()
                    
                    //Flash toggle button
                    Button {
                        self.viewModel.hasFlash.toggle()
                    } label: {
                        CameraOptionView(image: Image(systemName: viewModel.hasFlash ? "bolt.fill" : "bolt.slash.fill"))
                    }
                    
                }.padding(.vertical, 4)
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    //Switch camera button
                    Button(action: {
                        cameraView.switchCamera()
                        isFrontFacing.toggle()
                    }, label: {
                        CameraOptionView(image: Image(systemName:"arrow.triangle.2.circlepath"), imageDimension: 32, circleDimension: 50)
                    })
                }
            }
        }
        .padding(.top, TOP_PADDING)
        .padding(.bottom, SCREEN_RATIO > 2 ? BOTTOM_PADDING + 100 : BOTTOM_PADDING + 48)
        .padding(.horizontal, 6)
        
    }
}


struct CameraOptionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    var topPadding: CGFloat = 0
    @Binding var color: Color
    
    init(image: Image, imageDimension: CGFloat = 20, circleDimension: CGFloat = 36, color: Binding<Color> = .constant(.white), topPadding: CGFloat = 0) {
        self.image = image
        self.imageDimension = imageDimension
        self.circleDimension = circleDimension
        self._color = color
        self.topPadding = topPadding
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: imageDimension, height: imageDimension)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 20 + topPadding)
            .background(
                Circle()
                    .frame(width: circleDimension, height: circleDimension)
                    .foregroundColor(Color(white: 0, opacity: 0.4))
            )
    }
}
