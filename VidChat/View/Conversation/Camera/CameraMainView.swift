//
//  CameraMainView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI

struct CameraMainView: View {
    
    @StateObject var viewModel = CameraViewModel.shared
    @State var isFrontFacing = true
    
    var cameraView = CameraView()
    
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            //video player
            if let url = viewModel.url {
                VideoPlayerView(url: url, showName: false)
                    .overlay(VideoOptions(), alignment: .bottom)
                    .background(Color.clear)
                    .zIndex(3)
            }
            
            //camera
            cameraView
                .overlay(CameraOptions(isFrontFacing: $isFrontFacing, cameraView: cameraView), alignment: .center)
            
            //flash view if there's front facing flash
            if viewModel.isRecording && isFrontFacing && viewModel.hasFlash {
                FlashView()
            }
            
        }
        .ignoresSafeArea()
        .background(Color.clear)
    }
    
    func startRecording() {
        cameraView.startRecording()
    }
    
    func stopRecording() {
        cameraView.stopRecording()
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

struct VideoOptions: View {
    @StateObject var viewModel = CameraViewModel.shared

    var body: some View {
        VStack {
            
            HStack {
                
                Spacer()
                
                // X button
                Button {
                    withAnimation {
                        viewModel.reset()
                    }
                } label: {
                    CamereraOptionView(image: Image("x"), imageDimension: 14, circleDimension: 32)
                }
            }
            
            Spacer()
            
            HStack {
                
                CamereraOptionView(image: Image(systemName: "square.and.arrow.down"), imageDimension: 25, circleDimension: 44)
                
                Spacer()
                
                SendButton()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

struct SendButton: View {
    @StateObject var viewModel = CameraViewModel.shared
    
    var body: some View {
        
        Button(action: {
            let url = viewModel.croppedUrl == nil ? viewModel.url! : viewModel.croppedUrl!
            withAnimation {
                ConversationViewModel.shared.addMessage(url: url, type: .Video)
                viewModel.reset()
                viewModel.hasSentWithoutCrop = viewModel.croppedUrl == nil
            }
        }, label: {
            HStack {
                Rectangle()
                    .frame(width: 110, height: 40)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .overlay(
                        HStack(spacing: 10) {
                            Text("Send")
                                .foregroundColor(.black)
                                .font(.system(size: 18, weight: .bold))
                            
                            Image(systemName: "location.north.fill")
                                .resizable()
                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.black)
                                .frame(width: 20, height: 20)
                                .scaledToFit()
                        }
                    )
            }
        })
    }
}

struct CameraOptions: View {
    
    @StateObject var viewModel = CameraViewModel.shared
    @Binding var isFrontFacing: Bool
    
    //height of extra space above and below camera
    let nonCameraHeight = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 16/9) // Camera aspect ratio is 16/9
    
    var cameraView: CameraView
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                //Flash toggle button
                Button {
                    self.viewModel.hasFlash.toggle()
                } label: {
                    CamereraOptionView(image: Image(systemName: viewModel.hasFlash ? "bolt.fill" : "bolt.slash.fill"))
                }
                
                Spacer()
                
                // X button
                Button {
                    withAnimation {
                        viewModel.reset()
                    }
                } label: {
                    CamereraOptionView(image: Image("x"), imageDimension: 14)
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
        .padding(.vertical, nonCameraHeight / 2 + 4)
        .padding(.horizontal, 6)
    }
}


struct CamereraOptionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    
    init(image: Image, imageDimension: CGFloat = 20, circleDimension: CGFloat = 36) {
        self.image = image
        self.imageDimension = imageDimension
        self.circleDimension = circleDimension
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
            .frame(width: imageDimension, height: imageDimension)
            .padding(20)
            .background(
                Circle()
                    .frame(width: circleDimension, height: circleDimension)
                    .foregroundColor(Color(.init(white: 0, alpha: 0.3)))
            )
    }
}
