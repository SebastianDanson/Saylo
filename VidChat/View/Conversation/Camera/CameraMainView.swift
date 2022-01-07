//
//  CameraMainView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI
import Kingfisher
import AVFoundation

struct CameraMainView: View {
    
    @StateObject var viewModel = CameraViewModel.shared
    @State var isFrontFacing = true
    
    var cameraView = CameraView()
    
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            //video player
            if let playerView = viewModel.videoPlayerView {
                
                VStack {
                    
                    playerView
                        .overlay(MediaOptions(), alignment: .bottom)
                        .background(Color.clear)
                        .padding(.top, TOP_PADDING)
                    
                    //
                    Spacer()
                    
                }.zIndex(3)
            }
            
            if let photo = viewModel.photo, AuthViewModel.shared.hasCompletedSignUp {
                
                VStack{
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: SCREEN_WIDTH, height: SCREEN_WIDTH * 16/9)
                        .overlay(MediaOptions(), alignment: .bottom)
                        .padding(.top, TOP_PADDING)
                    Spacer()
                }.zIndex(3)
            }
            
            //camera
            cameraView
                .frame(width: SCREEN_WIDTH, height: screenHeight)
                .onTapGesture(count: 2, perform: {
                    switchCamera()
                })
            
            
            
            
            //flash view if there's front facing flash
            
            
            //            ZStack(alignment: .top) {
            
            
            //            }
        }
        
        .overlay(
            ZStack {
                VStack{
                    RoundedRectangle(cornerRadius: 24).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 10))
                        .frame(width: SCREEN_WIDTH + 18, height: SCREEN_WIDTH * 16/9 + 20)
                        .padding(.top, TOP_PADDING - 10)
                    Spacer()
                }
                
                if (viewModel.isRecording || viewModel.isTakingPhoto) && isFrontFacing && viewModel.hasFlash {
                    FlashView().zIndex(4)
                }
                
                if AuthViewModel.shared.hasCompletedSignUp {
                    CameraOptions(isFrontFacing: $isFrontFacing, cameraView: cameraView).padding(.horizontal, 4).zIndex(6)
                }
            }
        )
        .ignoresSafeArea()
        .background(Color(white: 0, opacity: 1))
        .navigationBarHidden(true)
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
        cameraView.addAudio()
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
        print("SETTING UP SESSION")
        cameraView.setupSession()
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
                        CamereraOptionView(image: Image("x"), imageDimension: 14, circleDimension: 32)
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                HStack {
                    
                    CamereraOptionView(image: Image(systemName: "square.and.arrow.down"), imageDimension: 25, circleDimension: 44)
                    
                    Spacer()
                    
                    SendButton()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
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
                } else {
                    conversationVM.sendCameraMessage(chatId: conversationVM.chatId, chat: conversationVM.selectedChat)
                    viewModel.reset(hideCamera: true)
                }
            }
        }, label: {
            
            
            HStack(spacing: 12) {
                
                Text(getSendText())
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .bold))
                
                Image(systemName: "location.north.fill")
                    .resizable()
                    .rotationEffect(Angle(degrees: 90))
                    .foregroundColor(.black)
                    .frame(width: 20, height: 20)
                    .scaledToFit()
            }
            .padding(.horizontal, 20)
            .frame(height: 40)
            .background(Color.white)
            .clipShape(Capsule())
            
            
        })
    }
    
    func getSendText() -> String {
        let viewModel = ConversationViewModel.shared
        
        if let chat = viewModel.selectedChat{
            return chat.name
        } else if viewModel.chatId == "" {
            return "Send To"
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
                        //}
                    } label: {
                        CamereraOptionView(image: Image("x"), imageDimension: 14)
                    }
                    
                    Spacer()
                    
                    //Flash toggle button
                    Button {
                        self.viewModel.hasFlash.toggle()
                    } label: {
                        CamereraOptionView(image: Image(systemName: viewModel.hasFlash ? "bolt.fill" : "bolt.slash.fill"))
                    }
                    
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    //Switch camera button
                    Button(action: {
                        cameraView.switchCamera()
                        isFrontFacing.toggle()
                    }, label: {
                        CamereraOptionView(image: Image(systemName:"arrow.triangle.2.circlepath"), imageDimension: 32, circleDimension: 50)
                    })
                }
            }
        }
        .padding(.top, TOP_PADDING)
        .padding(.bottom, BOTTOM_PADDING + 100)
        .padding(.horizontal, 6)
        
    }
}


struct CamereraOptionView: View {
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
                    .foregroundColor(Color(.init(white: 0, alpha: 0.4)))
            )
    }
}
