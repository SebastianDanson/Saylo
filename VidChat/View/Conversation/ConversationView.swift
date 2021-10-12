//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI

struct ConversationView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @ObservedObject var viewModel = ConversationViewModel.shared
    
    private let width = UIScreen.main.bounds.width
    private let cameraHeight = UIScreen.main.bounds.width * 1.25
    private let screenHeight = UIScreen.main.bounds.height
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            //Feed
            ScrollView {
                
                LazyVStack(spacing: 20) {
                    
                  //  Rectangle().frame(height: 100).foregroundColor(.white)
                    TextCell()
                    TextCell()
                    TextCell()
                    TextCell()
                    TextCell()

                    ForEach(viewModel.messages) { message in
                        MessageCell(message: message)
                    }
                    
                  //  Rectangle().frame(height: 100).foregroundColor(.white)
               
                
                   
                }.flippedUpsideDown()
                
            }.flippedUpsideDown()
            
            //Camera
            if CameraViewModel.shared.showCamera {
                CameraViewModel.shared.cameraView
                    .transition(.move(edge: .bottom))
                    .frame(height: cameraHeight + (screenHeight - cameraHeight)/2)
            }
           
        }
        .overlay(OptionsView().transition(.opacity), alignment: .bottom)
        .edgesIgnoringSafeArea(.all)
    }
    
}


/* The 5 buttons at the bottom of the chat */

struct OptionsView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        HStack(spacing: 4) {
            if cameraViewModel.url == nil {
                if !cameraViewModel.isRecording {
                    
                    //Camera button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "camera.fill"), imageDimension: 30, circleDimension: 50)
                    })
                    
                    //Photos button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 31, circleDimension: 50)
                    })
                    
                }
                
                //Video record circle
                Button(action: {
                    withAnimation {
                        cameraViewModel.handleTap()
                    }
                }, label: {
                    CameraCircle().padding(.horizontal, 10)
                })
                
                if !cameraViewModel.isRecording {
                    
                    //Mic button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "mic.fill"), imageDimension: 27, circleDimension: 50)
                    })
                    
                    //Aa button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "textformat.alt"), imageDimension: 32, circleDimension: 50)
                    })
                    
                }
            }
        }
        .frame(height: 70)
        .clipShape(Capsule())
        .padding(.bottom, bottomPadding + (cameraViewModel.isRecording ? 20 : 0))
    }
}

/* The button that records video */
struct CameraCircle: View {
    @StateObject var viewModel = CameraViewModel.shared
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
            .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: 6,
                                                       lineCap: .round,
                                                       lineJoin: .round))
            .animation(.linear(duration: viewModel.progress == 0 ? 0 : 20), value: viewModel.progress)
            .frame(width: 60, height: 60)
            .rotationEffect(Angle(degrees: 270))
            .overlay(
                Circle()
                    .strokeBorder(viewModel.isRecording ? Color.clear : Color(.systemGray), lineWidth: viewModel.isRecording ? 3 : 6)
                    .background(
                        VStack {
                            RoundedRectangle(cornerRadius: viewModel.isRecording ? 6:28)
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

/* The buttons along the bottom of the chat (camera, photos, audio, text buttons) */

struct ActionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    let color: Color
    
    init(image: Image, imageDimension: CGFloat = 32, circleDimension: CGFloat = 60, color: Color = Color(.systemGray)) {
        self.image = image
        self.imageDimension = imageDimension
        self.circleDimension = circleDimension
        self.color = color
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: imageDimension, height: imageDimension)
            .padding(20)
    }
}
