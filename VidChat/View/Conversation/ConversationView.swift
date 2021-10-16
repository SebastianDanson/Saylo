//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Combine
import AVKit
import Kingfisher

struct ConversationView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @ObservedObject var viewModel = ConversationViewModel.shared
    @ObservedObject var audioRecorder: AudioRecorder
    
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    @State private var dragOffset = CGSize.zero
    @State private var canScroll = true
    @State private var text = ""
    @State private var isTyping = false
    @State private var isRecordingAudio = false
    @State private var hasScrolledToVideo = false
    
    private let width = UIScreen.main.bounds.width
    private let cameraHeight = UIScreen.main.bounds.width * 1.25
    private let screenHeight = UIScreen.main.bounds.height
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        
        VStack() {
            
            ZStack {
                
                //Feed
                
                ScrollView(axes: .vertical, showsIndicators: false, offsetChanged: { point in
                    print(point, "POINT")
                    hasScrolledToVideo = false
                }) {
                    
                    ScrollViewReader { reader in
                        
                        LazyVStack(spacing: 12) {
                            Rectangle().frame(height: 100).foregroundColor(.white).offset(x: 0, y: dragOffset.height - 8)
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, element in
                                withAnimation {
                                    MessageCell(message: viewModel.messages[i])
                                        .transition(.move(edge: .bottom))
                                        .offset(x: 0, y: dragOffset.height - 8)
                                        .simultaneousGesture(
                                            viewModel.messages[i].type == .Video ?
                                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                                .onChanged { gesture in
                                                    dragOffset.height = gesture.translation.height
                                                    hasScrolledToVideo = true
                                                    viewModel.players.first(where: {$0.messageId == viewModel.messages[i].id})?.player.play()
                                                    
                                                }
                                                .onEnded { gesture in
                                                    handleOnDragEnd(translation: gesture.translation, index: i, reader: reader)
                                                } : nil
                                        )
                                }
                            }
                            
                            if !isTyping {
                                Rectangle().frame(height: 100).foregroundColor(.white)
                                    .offset(x: 0, y: dragOffset.height - 8)
                                    .transition(.slide)
                            }
                            
                            
                        }.flippedUpsideDown()
                    }
                }
                .flippedUpsideDown()
                
                
                //Camera
                if CameraViewModel.shared.showCamera {
                    CameraViewModel.shared.cameraView
                        .transition(.move(edge: .bottom))
                }
            }
            
            PhotoPickerView().frame(width: width, height: width/4*3)

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
                                ConversationViewModel.shared.addMessage(text: text, type: .Text)
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
                }.transition(.move(edge: .bottom))
            }
        }
        .overlay(
            ZStack {
                if !isTyping {
                    VStack {
                        
                        if !cameraViewModel.showCamera {
                            ChatOptions()
                        }
                        
                        Spacer()
                        
                        OptionsView(audioRecorder: audioRecorder, isTyping: $isTyping, isRecordingAudio: $isRecordingAudio)
                            .transition(.opacity)
                    }
                    
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
            if viewModel.messages.count > i + 1 {
                handleOnDragEndScroll(currentIndex: i, nextIndex: i+1)
            }
        }
        
        if translation.height > 0 {
            if i - 1 >= 0 {
                handleOnDragEndScroll(currentIndex: i, nextIndex: i-1)
            }
        }
        
        func handleOnDragEndScroll(currentIndex: Int, nextIndex: Int) {
            if hasScrolledToVideo {
                if let currentMessagePlayer = viewModel.players.first(where: { $0.messageId == viewModel.messages[currentIndex].id }) {
                    currentMessagePlayer.player.pause()
                }
                
                if let nextMessagePlayer = viewModel.players.first(where: { $0.messageId == viewModel.messages[nextIndex].id }) {
                    nextMessagePlayer.player.seek(to: CMTime.zero)
                    nextMessagePlayer.player.play()
                }
                
                withAnimation() {
                    reader.scrollTo(viewModel.messages[nextIndex].id, anchor: .center)
                    canScroll = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    hasScrolledToVideo = true
                }
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    hasScrolledToVideo = true
                }
            }
            
            hasScrolledToVideo = true
        }
    }
}



/* The 5 buttons at the bottom of the chat */

struct OptionsView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @ObservedObject var audioRecorder: AudioRecorder
    
    @Binding var isTyping: Bool
    @Binding var isRecordingAudio: Bool
    
    @State var audioProgress = 0.0

    var body: some View {
        
        HStack(spacing: 4) {
            if cameraViewModel.url == nil {
                if !cameraViewModel.isRecording {
                    
                    if !isRecordingAudio {
                        //Camera button
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "camera.fill"), imageDimension: 30)
                        })
                    }
                    
                    if !isRecordingAudio {
                        //Photos button
                        Button(action: {}, label: {
                            ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 31)
                        })
                    }
                    
                }
                
                if !isRecordingAudio {
                //Video record circle
                Button(action: {
                    withAnimation {
                        cameraViewModel.handleTap()
                    }
                }, label: {
                    CameraCircle().padding(.horizontal, 10)
                })
                }
                
                if !cameraViewModel.isRecording {
                    
                    //Mic button
                    Button(action: {
                        withAnimation {
                            audioProgress = !audioRecorder.recording ? 1.0 : 0.0
                            isRecordingAudio = !audioRecorder.recording
                        }
                        audioRecorder.recording ? audioRecorder.stopRecording() : audioRecorder.startRecording()
                    }, label: {
                        ActionView(image: Image(systemName: "mic.fill"), imageDimension: 27, isActive: $isRecordingAudio)
                            .foregroundColor(audioRecorder.recording ? Color.mainBlue : Color(.systemGray))
                            .overlay(
                                ZStack {
                               // if isRecordingAudio {
                                    Circle()
                                        .trim(from: 0.0, to: CGFloat(min(audioProgress, 1.0)))
                                        .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: 5,
                                                                                   lineCap: .round,
                                                                                   lineJoin: .round))
                                        .animation(.linear(duration: audioProgress == 0 ? 0 : 20), value: audioProgress)
                                        .frame(width: 48, height: 48)
                                        .rotationEffect(Angle(degrees: 270))
                               // }
                                }
                            )
                    })
                    
                    if !isRecordingAudio {
                        //Aa button
                        Button(action: {
                            withAnimation {
                                isTyping = true
                            }
                        }, label: {
                            ActionView(image: Image(systemName: "textformat.alt"), imageDimension: 32)
                        })
                    }
                    
                }
            }
        }
        .frame(height: 70)
        .clipShape(Capsule())
        .padding(.bottom, cameraViewModel.isRecording ? 50 : -2)
    }
}

/* The button that records video */

struct CameraCircle: View {
    @StateObject var viewModel = CameraViewModel.shared
    
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
                        VStack {
                            RoundedRectangle(cornerRadius: viewModel.isRecording ? 6:28)
                                .frame(width: viewModel.isRecording ? 28:0,
                                       height: viewModel.isRecording ? 28:0)
                                .foregroundColor(Color(.systemRed))
                                .transition(.scale)
                        }
                    )
                    .frame(width: 60, height: 60)
            )
    }
}

/* The top right buttons */

struct ChatOptions: View {
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            Image(systemName: "chevron.left.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(.systemGray2))
                .background(Circle().foregroundColor(.white).frame(width: 28, height: 28))
                .frame(width: 30, height: 30)
                .padding(.vertical, 10)
            
            Spacer()
            
            KFImage(URL(string: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%202.54.09%20PM.png?alt=media&token=0a1b499c-a2d9-416f-ab99-3f965939ed66"))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .padding(.vertical, 10)
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding + 4)
    }
}

/* The buttons along the bottom of the chat (camera, photos, audio, text buttons) */

struct ActionView: View {
    
    let image: Image
    let imageDimension: CGFloat
    
    @Binding var isActive: Bool
    
    init(image: Image, imageDimension: CGFloat = 32, isActive: Binding<Bool> = .constant(false)) {
        self.image = image
        self.imageDimension = imageDimension
        self._isActive = isActive
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(isActive ? Color.mainBlue : Color(.systemGray))
            .frame(width: imageDimension, height: imageDimension)
            .padding(20)
    }
}


private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content
    
    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
        SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
            }.frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
    }
}