//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI

struct ConversationView: View {
    
    let width = UIScreen.main.bounds.width
    let cameraHeight = UIScreen.main.bounds.width * 1.25
    let screenHeight = UIScreen.main.bounds.height
    @StateObject var viewModel: CameraViewModel
    @State var showCamera = false
    let cameraView = CameraMainView()
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(.white)
                    
                    //  VideoPlayerView(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/video.MOV%20(1).mp4?alt=media&token=a70ab00a-5ca7-4bd0-ae76-c16a09e40a3a")!)
                    
                    TextCell()
                    TextCell()
                    TextCell()
                    TextCell()
                    TextCell()
                    
                    
                    if let url = viewModel.url, !viewModel.showCamera{
                        VideoPlayerView(url: url)
                            .frame(width: width, height: cameraHeight)
                    }
                    
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(.white)
                }.flippedUpsideDown()
            }.flippedUpsideDown()
            
            
            if viewModel.showCamera {
                cameraView
                    .animation(.linear)
                    .frame(height: cameraHeight + (screenHeight - cameraHeight)/2)
            }
            
        }
        .overlay(
            HStack(spacing: 4) {
                if viewModel.url == nil {
                    
                    if !viewModel.isRecording {
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "camera.fill"), imageDimension: 28, circleDimension: 50)
                        })
                        
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 28, circleDimension: 50)
                        })
                    }
                    Button(action: {
                        if !viewModel.isRecording {
                            withAnimation {
                                viewModel.isRecording = true
                                viewModel.showCamera = true
                            }
                            viewModel.progress = 1
                        } else {
                            withAnimation {
                                viewModel.isRecording = false
                            }
                            viewModel.progress = 0
                        }
                    }, label: {
                        CameraCircle().padding(.horizontal, 10)
                    })
                    
                    if !viewModel.isRecording {
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "mic.fill"), imageDimension: 28, circleDimension: 50)
                        })
                        
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "message.fill"), imageDimension: 28, circleDimension: 50)
                        })
                    }
                }
            }
            .frame(height: 70)
            .clipShape(Capsule())
            .padding(.bottom, bottomPadding + (viewModel.isRecording ? 20 : 0)) ,alignment: .bottom
            //            OptionsView(showCamera: $showCamera), alignment: .bottom
        )
        .environmentObject(viewModel)
        .edgesIgnoringSafeArea(.all)
    }
    
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}

struct OptionsView: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        HStack(spacing: 20) {
            if !viewModel.showCamera {
                Button(action: {}, label: {
                    ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 28, circleDimension: 50)
                })
            }
            Button(action: {
                if !viewModel.showCamera {
                    withAnimation {
                        viewModel.showCamera = true
                    }
                } else {
                    viewModel.hasRecordedVideo = true
                }
            }, label: {
                Rectangle().overlay(
                    CameraCircle()
                )
                .frame(width: 70, height: 70)
                .foregroundColor(Color(.init(white: 0, alpha: 0.6)))
                .clipShape(Circle())
                // .background(Color.black)
                
            })
            
            if !viewModel.showCamera {
                Button(action: {}, label: {
                    ActionView(image: Image(systemName: "message.fill"), imageDimension: 28, circleDimension: 50)
                })
            }
            
        }
        .frame(width: 250, height: 70)
        .clipShape(Capsule())
        .padding(.bottom, bottomPadding + (viewModel.showCamera ? 20 : 0))
    }
}

struct CameraCircle: View {
    @EnvironmentObject var viewModel: CameraViewModel
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
            .stroke(Color.white, style: StrokeStyle(lineWidth: 6,
                                                    lineCap: .round,
                                                    lineJoin: .round))
            .animation(.linear(duration: viewModel.progress == 0 ? 0 : 20), value: viewModel.progress)
            .frame(width: 60, height: 60)
            .rotationEffect(Angle(degrees: 270))
            .overlay(
                Circle()
                    .strokeBorder(viewModel.isRecording ? Color.clear : Color(.systemGray), lineWidth: viewModel.isRecording ? 3 : 6)
                    .background(
                        VStack {                                RoundedRectangle(cornerRadius: viewModel.isRecording ? 6:28)
                            .frame(width: viewModel.isRecording ? 28:0,
                                   height: viewModel.isRecording ? 28:0)
                            .foregroundColor(.red)
                            .transition(.scale)
                        }
                    )
                    .frame(width: 60, height: 60)
            )
    }
}
