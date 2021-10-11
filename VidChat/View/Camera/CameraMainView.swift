//
//  CameraMainView.swift
//  VidChat
//
//  Created by Student on 2021-09-27.
//

import SwiftUI

struct CameraMainView: View {
    
    @State var isFlash = false
    
    var cameraView = CameraView()
    @EnvironmentObject var viewModel: CameraViewModel
    @State var hasFinishedRecording: Bool = false
    @State var isFrontFacing = true
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    let cameraHeight = UIScreen.main.bounds.width * 1.25
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                if let url = viewModel.url {
                    VideoPlayerView(url: url)
                        .background(Color.clear)
                        .zIndex(3)
                }
                
                cameraView
                    .environmentObject(viewModel)
                    .overlay(
                        HStack {
                            if !viewModel.isRecording {
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
                        }, alignment: .top)
                    .background(Color.black)
                
                if viewModel.isRecording && isFrontFacing && isFlash {
                    FlashView()
                }
                
            }
            
            HStack(alignment: .center) {                
                Spacer()
                //                Button {
                //                    if !isRecording {
                //                        cameraView.startRecording(withFlash: isFlash)
                //                        progress = 1
                //                    } else {
                //                        cameraView.stopRecording()
                //                        progress = 0
                //                        hasFinishedRecording = true
                //                    }
                //                    withAnimation {
                //                        isRecording.toggle()
                //                    }
                //                } label: {
                //                    CameraCircle(isRecording: $isRecording,
                //                                 progress: $progress)
                //                }
                
                //                Spacer()
                //
                
                if viewModel.isRecording {
                    Button(action: {
                        cameraView.switchCamera()
                        isFrontFacing.toggle()
                    }, label: {
                        ActionView(image: Image(systemName:"arrow.triangle.2.circlepath"))
                            .padding(.bottom, 10)
                    })
                }
                
                if viewModel.url != nil {
                    VStack {
//                        HStack {
//                            Spacer()
//
//                            Button(action: {viewModel.url = nil}, label: {
//                                ActionView(image: Image("x"),
//                                           imageDimension: 16, circleDimension: 36)
//                            })
//
//
//                        }
//                        Spacer()
                        
                        HStack {
                            ActionView(image: Image(systemName: "square.and.arrow.down"),
                                       imageDimension: 28, circleDimension: 60)
                            Spacer()
                            Button(action: {
                                if viewModel.url != nil {
                                    viewModel.reset()
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
                        .padding(20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .frame(height: (screenHeight - cameraHeight)/2)
            .background(Color.black)
            // }
            
            //            Rectangle()
            //                .frame(height: bottomPadding)
            //                .foregroundColor(.black)
            //             }
        }
        .background(Color.clear)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startRecording()
            }
        })
    }
    
    func startRecording() {
        cameraView.startRecording()
    }
    
    func stopRecording() {
        cameraView.stopRecording()
    }
}

//struct CameraMainView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraMainView(viewModel: CameraViewModel(), showCamera: .constant(true))
//    }
//}

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
            .foregroundColor(Color(.systemGray))
            .frame(width: imageDimension, height: imageDimension)
            .padding(20)
//            .background(
//                Circle()
//                    .frame(width: circleDimension, height: circleDimension)
//                    .foregroundColor(Color(.init(white: 0, alpha: 0.6)))
//            )
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
