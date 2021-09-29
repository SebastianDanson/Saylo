//
//  CameraMainView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI

struct CameraMainView: View {
    
    @State var isRecording = false
    @State var isFlash = false
    
    var cameraView = CameraView()
    @StateObject var viewModel: CameraViewModel
    @State var hasFinishedRecording: Bool = false
    @Binding var showCamera: Bool
    @State private var progress = 0.0
    @State var isFrontFacing = true
    
    var body: some View {
        VStack {
            ZStack {
                 if let url = viewModel.url {
                    VideoPlayerView(url: url)
                        .background(Color.clear)
                        .zIndex(3)
                }
                    cameraView.ignoresSafeArea()
                
                if isRecording && isFrontFacing && isFlash {
                    FlashView()
                }
                
                VStack {
                    HStack {
                        if !isRecording {
                            Button {
                                self.isFlash.toggle()
                            } label: {
                                ActionView(image:
                                            Image(systemName: isFlash ?
                                                    "bolt.fill" : "bolt.slash.fill"),
                                           imageDimension: 20, circleDimension: 36)
                                    .padding(.leading, 4)
                                    .padding(.top, -4)
                            }
                            Spacer()
                            
                            Button {
                                self.showCamera = false
                            } label: {
                                ActionView(image: Image("x"),
                                           imageDimension: 16, circleDimension: 36)
                                    .padding(.trailing, 4)
                                    .padding(.top, -4)
                            }
                        }
                    }
                    Spacer()
                    HStack(alignment: .center) {
                        Spacer()
                        
                        ActionView(image: Image(systemName: "photo"),
                                   imageDimension: 30)
                            .opacity(isRecording ? 0 : 1)
                        
                        Spacer()
                        Button {
                            if !isRecording {
                                cameraView.startRecording(withFlash: isFlash)
                                progress = 1
                            } else {
                                cameraView.stopRecording()
                                progress = 0
                                hasFinishedRecording = true
                            }
                            withAnimation {
                                isRecording.toggle()
                            }
                        } label: {
                            CameraCircle(isRecording: $isRecording,
                                         progress: $progress)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            cameraView.switchCamera()
                            isFrontFacing.toggle()
                        }, label: {
                            ActionView(image: Image(systemName:"arrow.triangle.2.circlepath"))
                        })
                        
                        
                        Spacer()
                        
                    }
                }
            
            }
        }
        .environmentObject(viewModel)
    }
}

struct CameraMainView_Previews: PreviewProvider {
    static var previews: some View {
        CameraMainView(viewModel: CameraViewModel(), showCamera: .constant(true))
    }
}

struct ActionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    
    init(image: Image, imageDimension: CGFloat = 32, circleDimension: CGFloat = 60) {
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

struct CameraCircle: View {
    @Binding var isRecording: Bool
    @Binding var progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
            .stroke(Color.white, style: StrokeStyle(lineWidth: 6,
                                                    lineCap: .round,
                                                    lineJoin: .round))
            .animation(.linear(duration: progress == 0 ? 0 : 20), value: progress)
            .frame(width: 80, height: 80)
            .rotationEffect(Angle(degrees: 270))
            .overlay(
                Circle()
                    .strokeBorder(isRecording ? Color.clear : Color.white, lineWidth: 5)
                    .background(
                        VStack {                                RoundedRectangle(cornerRadius: isRecording ? 8:37)
                            .frame(width: isRecording ? 34:64,
                                   height: isRecording ? 34:64)
                            .foregroundColor(isRecording ? .red : .white)
                            .transition(.scale)
                        }
                    )
                    .frame(width: 80, height: 80)
            )
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
