//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Combine

struct ConversationView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @ObservedObject var viewModel = ConversationViewModel.shared
    
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    @State private var dragOffset = CGSize.zero
    @State private var canScroll = true
    @State private var text = ""
    @State private var isTyping = false
    
    private let width = UIScreen.main.bounds.width
    private let cameraHeight = UIScreen.main.bounds.width * 1.25
    private let screenHeight = UIScreen.main.bounds.height
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    let colors: [Color] = [.red, .green, .blue]
    let prevCOntentOffset: CGFloat = 0
    
    var body: some View {
        
        
        VStack() {
            ZStack {
                //Feed
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ScrollViewReader { reader in
                        
                        LazyVStack(spacing: 12) {
                            Rectangle().frame(height: 100).foregroundColor(.white).offset(x: 0, y: dragOffset.height)
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, element in
                                withAnimation {
                                    MessageCell(message: viewModel.messages[i])
                                        .transition(.move(edge: .bottom))
                                        .offset(x: 0, y: dragOffset.height)
                                        .simultaneousGesture(
                                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                                .onChanged { gesture in
                                                    dragOffset.height = gesture.translation.height
                                                }
                                                .onEnded { gesture in
                                                    handleOnDragEnd(translation: gesture.translation, index: i, reader: reader)
                                                }
                                        )
                                        .allowsHitTesting(canScroll)
                                }
                            }
                            
                            if !isTyping {
                                Rectangle().frame(height: 100).foregroundColor(.white)
                                    .offset(x: 0, y: dragOffset.height)
                                    .transition(.slide)
                            }
                            
                            
                        }.flippedUpsideDown()
                    }
                }.flippedUpsideDown()
                
                //Camera
                if CameraViewModel.shared.showCamera {
                    CameraViewModel.shared.cameraView
                        .transition(.move(edge: .bottom))
                }
            }
            
            if isTyping {
                HStack(alignment: .bottom) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "house")
                            .clipped()
                            .scaledToFit()
                            .padding()
                            .background(Color.gray)
                            .frame(width: 28, height: 28)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sebastian")
                                .font(.system(size: 14, weight: .semibold))
                            MultilineTextField(text: $text) {
                                isTyping = false
                            }
                        }
                        Spacer()
                    }.padding(.leading)
                    
                    Button {
                        if !text.isEmpty {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                ConversationViewModel.shared.addMessage(text: text)
                                text = ""
                            }
                        }
                    } label: {
                        ZStack {
                            if text != "" {
                                Image(systemName: "arrow.up.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(Color.mainBlue)
                                    .transition(.move(edge: .trailing))
                            }
                        }
                    }
                    .padding(.bottom, 9)
                    .padding(.trailing, 10)
                    
                }
                
            }
            
        }
        .overlay(
            ZStack {
                if !isTyping {
                    OptionsView(isTyping: $isTyping).transition(.opacity)
                        .transition(.opacity)
                }
            }
            ,alignment: .bottom)
        .edgesIgnoringSafeArea(.top)
        
    }
    
    func handleOnDragEnd(translation: CGSize, index i: Int, reader: ScrollViewProxy) {

        withAnimation(.easeInOut(duration: 0.3)) {
            dragOffset = .zero
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            canScroll = true
        }
        
        if translation.height < 0 {
            if i + 1 < viewModel.messages.count && viewModel.messages[i + 1].type == .Video {
                withAnimation() {
                    reader.scrollTo(viewModel.messages[i + 1].id, anchor: .center)
                    canScroll = false
                }
            }
        }
        
        if translation.height > 0 {
            if i - 1 >= 0 && viewModel.messages[i - 1].type == .Video {
                withAnimation() {
                    reader.scrollTo(viewModel.messages[i - 1].id, anchor: .center)
                    canScroll = false
                }
            }
        }
    }
    
}


/* The 5 buttons at the bottom of the chat */

struct OptionsView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @Binding var isTyping: Bool
    
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
                    Button(action: {
                        withAnimation {
                            isTyping = true
                        }
                    }, label: {
                        ActionView(image: Image(systemName: "textformat.alt"), imageDimension: 32, circleDimension: 50)
                    })
                    
                }
            }
        }
        .frame(height: 70)
        .clipShape(Capsule())
        .padding(.bottom, cameraViewModel.isRecording ? 50 : 0)
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
    }
}
