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
    let cameraHeight = UIScreen.main.bounds.width * 1.25
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .top) {
                
                //video player
                if let url = viewModel.url {
                    VideoPlayerView(url: url, isCustomVideo: true).background(Color.clear).zIndex(3)
                }
                
                //camera
                cameraView
                    .overlay(CameraOptions(), alignment: .top)
                    .background(Color.black)
                
                //flash view if there's front facing flash
                if viewModel.isRecording && isFrontFacing && viewModel.hasFlash {
                    FlashView()
                }
    
            }
            
            //View at the bottom of the camera and video player with various options
            HStack(alignment: .center) {                
                Spacer()
       
                if viewModel.isRecording {
                    
                    //Switch camera button
                    Button(action: {
                        cameraView.switchCamera()
                        isFrontFacing.toggle()
                    }, label: {
                        ActionView(image: Image(systemName:"arrow.triangle.2.circlepath"))
                            .padding(.bottom, 10)
                    })
                    
                }
                
                if viewModel.url != nil {
                    VideoOptions()
                }
            }
            .frame(height: (screenHeight - cameraHeight)/2)
            .background(Color.white)
        }
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
                
                ActionView(image: Image(systemName: "square.and.arrow.down"),
                           imageDimension: 28, circleDimension: 60)
                
                Spacer()
                
                Button(action: {
                    if let url = viewModel.croppedUrl {
                        withAnimation {
                            ConversationViewModel.shared.addMessage(url: url.absoluteString)
                            viewModel.reset()
                        }
                    }
                }, label: {
                    SendButton()
                })
            }
            .padding(20)
            .padding(.bottom, 30)
        }
    }
}

struct SendButton: View {
    var body: some View {
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
    }
}

struct CameraOptions: View {
    
    @StateObject var viewModel = CameraViewModel.shared

    var body: some View {
        
        HStack {
            
            if !viewModel.isRecording {
                
                //Flash toggle button
                Button {
                    self.viewModel.hasFlash.toggle()
                } label: {
                    ActionView(image:
                                Image(systemName: viewModel.hasFlash ?
                                      "bolt.fill" : "bolt.slash.fill"),
                               imageDimension: 20, circleDimension: 36, color: .white)
                        .padding(.leading, 4)
                        .padding(.top, -4)
                }
                
                Spacer()
                
                //X button
                Button {
                    withAnimation {
                        viewModel.reset()
                    }
                } label: {
                    ActionView(image: Image("x"),
                               imageDimension: 16, circleDimension: 36)
                        .padding(.trailing, 4)
                        .padding(.top, -4)
                }
            }
        }
    }
}
