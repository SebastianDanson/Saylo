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
    
    @Environment(\.presentationMode) var mode
    
    @StateObject var cameraViewModel = CameraViewModel.shared
    @StateObject var viewModel = ConversationViewModel.shared
    
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    @State private var dragOffset = CGSize.zero
    @State private var text = ""
    @State private var photosPickerHeight = PHOTO_PICKER_BASE_HEIGHT
    @State private var showSettings = false
    
    private var isFirstLoad = true
    private let cameraHeight = SCREEN_WIDTH * 1.25
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                
                ZStack {
                    
                    //Feed
                    //                LazyVStack(spacing: 12) {
                    
                    if !viewModel.showSavedPosts {
                        
                        ConversationFeedView(showSavedPosts: false)
                        
                    }
                    //Camera
                    if viewModel.showCamera {
                        CameraViewModel.shared.cameraView
                            .zIndex(6)
                    }
                    
                    if showSettings {
                        Button {
                            withAnimation(.linear(duration: 0.1)) {
                                showSettings = false
                            }
                        } label: {
                            Rectangle()
                                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                                .foregroundColor(.clear)
                        }
                    }
                }
                
                if viewModel.showPhotos {
                    PhotoPickerView(baseHeight: PHOTO_PICKER_BASE_HEIGHT, height: $photosPickerHeight)
                        .frame(width: SCREEN_WIDTH, height: photosPickerHeight)
                        .transition(.move(edge: .bottom))
                }
                
                
                if viewModel.showKeyboard {
                    KeyboardView(text: $text)
                }
                
                
            }
            .overlay(
                ZStack {
                    if !viewModel.showKeyboard {
                        
                        VStack {
                            
                            if !viewModel.showCamera {
                                ChatOptions(showSettings: $showSettings)
                            }
                            
                            Spacer()
                            
                            OptionsView()
                        }
                    }
                }
                ,alignment: .bottom)
            
            if viewModel.showConversationPlayer {
                ConversationPlayerView()
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .move(edge: .bottom)))
                    .zIndex(6)
            }
            
            if viewModel.showImageDetailView {
                ImageDetailView()
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .move(edge: .bottom)))
                    .zIndex(6)
            }
            
            if viewModel.showSavedPosts {
                ConversationFeedView(showSavedPosts: true)
                    .background(Color.white)
                    .overlay(SavedPostsOptionsView(), alignment: .bottom)
                    .transition(.move(edge: .bottom))
                    .zIndex(6)
            }
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(viewModel.showKeyboard ? .top : .all)
    }
    
}



/* The 5 buttons at the bottom of the chat */

struct OptionsView: View {
    
    
    @StateObject var cameraViewModel = CameraViewModel.shared
    @StateObject var viewModel = ConversationViewModel.shared
    
    @State var audioRecorder = AudioRecorder()
    @State var audioProgress = 0.0
    @State var isRecordingAudio = false
    
    var body: some View {
        
        ZStack {
            
            if !viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard {
                VisualEffectView(effect: UIBlurEffect(style: .regular))
            }
            VStack {
                
                
                HStack(spacing: 0) {
                    
                    if !viewModel.showPhotos && !viewModel.showKeyboard {
                        
                        if cameraViewModel.videoUrl == nil && cameraViewModel.photo == nil {
                            
                            if !viewModel.showCamera {
                                
                                if !isRecordingAudio {
                                    //Camera button
                                    Button(action: {
                                        withAnimation(.linear(duration: 0.15)) {
                                            cameraViewModel.isShowingPhotoCamera = true
                                            viewModel.showCamera = true
                                        }
                                    }, label: {
                                        ActionView(image: Image(systemName: "camera.fill"), imageDimension: 30)
                                    }).transition(.scale)
                                }
                                
                                if !isRecordingAudio {
                                    
                                    Button(action: {
                                        withAnimation(.linear(duration: 0.15)) {
                                            viewModel.showPhotos = true
                                        }
                                    }, label: {
                                        ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 31)
                                    }).transition(.scale)
                                    
                                    //Photos button
                                    
                                }
                            }
                            
                            if !isRecordingAudio {
                                //Video record circle
                                Button(action: {
                                    
                                    cameraViewModel.handleTap()
                                    
                                    //                                    withAnimation {
                                    viewModel.showCamera = true
                                    //                                    }
                                    viewModel.players.forEach({ $0.player.pause() })
                                    
                                }, label: {
                                    CameraCircle().padding(.leading, 15).padding(.trailing, 12)
                                }).transition(.scale)
                            }
                            
                            if !viewModel.showCamera {
                                
                                //Mic button
                                Button(action: {
                                    withAnimation {
                                        if !isRecordingAudio {
                                            audioProgress = 1.0
                                            viewModel.showAudio = true
                                            audioRecorder.startRecording()
                                        } else {
                                            audioProgress = 0.0
                                            
                                            if !viewModel.showAudio {
                                                audioRecorder.audioPlayer.isPlaying ?
                                                audioRecorder.pauseRecording() : audioRecorder.playRecording()
                                            } else {
                                                audioRecorder.stopRecording()
                                            }
                                            
                                            viewModel.showAudio = false
                                        }
                                        isRecordingAudio = true
                                    }
                                }, label: {
                                    ActionView(image: Image(systemName: viewModel.showAudio || !isRecordingAudio ? "waveform" :
                                                                cameraViewModel.isPlaying ?
                                                            "pause.circle.fill" : "play.circle.fill"),
                                               imageDimension: viewModel.showAudio || !isRecordingAudio ? 30 : 60, isActive: $isRecordingAudio, isAudio: true)
                                        .foregroundColor(isRecordingAudio ? Color.mainBlue : Color(.systemGray))
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
                                            viewModel.showKeyboard = true
                                        }
                                    }, label: {
                                        ActionView(image: Image(systemName: "textformat.alt"), imageDimension: 32)
                                    }).transition(.scale)
                                }
                                
                            }
                        }
                    }
                }
                .frame(height: 70)
                .padding(.bottom, viewModel.showCamera ? 200 + BOTTOM_PADDING : BOTTOM_PADDING)
                .padding(.horizontal, 14)
                .overlay(AudioOptions(audioRecorder: $audioRecorder, isRecordingAudio: $isRecordingAudio))
                .transition(.opacity)
                
            }
        }
        
        .frame(width: SCREEN_WIDTH, height: BOTTOM_PADDING + 70)
        .background(!viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard ? Color(white: 1, opacity: 0.7) : Color.clear)
        
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

/* The button that records video */

struct CameraCircle: View {
    @StateObject var viewModel = CameraViewModel.shared
    
    var body: some View {
        
        Circle()
            .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
            .stroke(Color.white, style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round))
            .animation(.linear(duration: viewModel.progress == 0 ? 0 : 20), value: viewModel.progress)
            .frame(width: 52, height: 52)
            .rotationEffect(Angle(degrees: 270))
            .overlay(
                Circle()
                    .stroke(LinearGradient(colors: [viewModel.isRecording ? .clear :
                                                        viewModel.isShowingPhotoCamera ? .white : .bottomGray,
                                                    viewModel.isRecording ? .clear :
                                                        viewModel.isShowingPhotoCamera ? .white : .topGray],
                                           startPoint: .bottom, endPoint: .top),
                            style: StrokeStyle(lineWidth: viewModel.isShowingPhotoCamera ? 7 : 5.5))
                    .background(
                        VStack {
                            if viewModel.isRecording {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: 26,
                                           height: 26)
                                    .foregroundColor(Color(.systemRed))
                                    .transition(.scale)
                            }
                        }
                    )
                    .frame(width: viewModel.isShowingPhotoCamera ? 64 : 52,
                           height: viewModel.isShowingPhotoCamera ? 64 : 52)
            )
            .padding(.horizontal, 8)
    }
}

/* The top right buttons */

struct ChatOptions: View {
    @Environment(\.presentationMode) var mode
    @Binding var showSettings: Bool
    
    @StateObject var viewModel = ConversationViewModel.shared
    @StateObject var cameraViewModel = CameraViewModel.shared
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    
    var body: some View {
        
        VStack {
            HStack(spacing: 0) {
                
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    
                    ZStack {
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundColor(Color(white: 0, opacity: 0.3))
                        
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .padding(.trailing, 3)
                        
                    }
                }
                
                Spacer()
                
                
                Button {
                    withAnimation(.linear(duration: 0.1)) {
                        showSettings.toggle()
                    }
                } label: {
                    KFImage(URL(string: viewModel.chat?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .padding(.vertical, 10)
                }
                
            }
            
            if showSettings {
                ChatSettingsView()
                    .zIndex(5)
                    .transition(.opacity)
            }
            
            
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    
                    Button {
                        withAnimation {
                            cameraViewModel.toggleIsFrontFacing()
                        }
                    } label: {
                        
                        ZStack {
                            
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundColor(Color(white: 0, opacity: 0.3))
                            
                            Image(cameraViewModel.isFrontFacing ? "frontCamera" : "rearCamera")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 24)
                        }
                    }
                    
                    if viewModel.messages.count > 0 {
                        
                        Button {
                            withAnimation(.linear(duration: 0.2)) {
                                viewModel.showConversationPlayer.toggle()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(Color(white: 0, opacity: 0.3))
                                
                                Image(systemName: "film")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
            }.padding(.vertical, -6)
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding)
    }
}

/* The buttons along the bottom of the chat (camera, photos, audio, text buttons) */

struct ActionView: View {
    
    let image: Image
    let imageDimension: CGFloat
    let isAudio: Bool
    @Binding var isActive: Bool
    
    init(image: Image, imageDimension: CGFloat = 32, isActive: Binding<Bool> = .constant(false), isAudio: Bool = false) {
        self.image = image
        self.imageDimension = imageDimension
        self._isActive = isActive
        self.isAudio = isAudio
    }
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isAudio && ConversationViewModel.shared.showAudio ? .mainBlue : .bottomGray, isAudio && ConversationViewModel.shared.showAudio ? .mainBlue : .topGray]), startPoint: .bottom, endPoint: .top)
            .mask(image
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageDimension, height: imageDimension)
                    .aspectRatio(contentMode: .fit))
    }
}


struct AudioOptions: View {
    
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    @StateObject var viewModel = ConversationViewModel.shared
    
    @Binding var audioRecorder: AudioRecorder
    @Binding var isRecordingAudio: Bool
    
    var body: some View {
        HStack{
            
            if !viewModel.showAudio && isRecordingAudio {
                
                Button {
                    audioRecorder.stopPlayback()
                    withAnimation {
                        isRecordingAudio = false
                    }
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color(.systemGray))
                        .padding(32)
                }.transition(.move(edge: .leading))
                
                Spacer()
                
                Button {
                    audioRecorder.sendRecording()
                    audioRecorder.stopPlayback()
                    withAnimation {
                        isRecordingAudio = false
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.mainBlue)
                        .padding(32)
                }.transition(.move(edge: .trailing))
            }
        }.padding(.bottom, bottomPadding)
    }
}


struct KeyboardView: View {
    
    @StateObject var viewModel = ConversationViewModel.shared
    @Binding var text: String
    let authViewModel = AuthViewModel.shared
    
    var body: some View {
        
        HStack(alignment: .bottom) {
            HStack(alignment: .top, spacing: 10) {
                KFImage(URL(string: authViewModel.currentUser?.profileImageUrl ?? ""))
                .clipped()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(authViewModel.currentUser?.profileImageUrl ?? "")
                        .font(.system(size: 14, weight: .semibold))
                    MultilineTextField(text: $text) {
                        viewModel.showKeyboard = false
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 12)
            .padding(.top, 4)
            
            Button {
                if !text.isEmpty {
                    withAnimation(.linear(duration: 0.15)) {
                        viewModel.addMessage(text: text, type: .Text)
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

struct ChatSettingsView: View {
    
    let chat = ConversationViewModel.shared.chat
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack(alignment: .center) {
                
                HStack(spacing: 12) {
                    
                    KFImage(URL(string: chat?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    
                    Text(chat?.name ?? "")
                        .lineLimit(1)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                ZStack {
                    
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(white: 0, opacity: 0.3))
                    
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                    
                }.padding(.trailing, 20)
                
            }
            .padding(.leading)
            .padding(.top)
            
            
            
            Button {
                
                if ConversationViewModel.shared.savedMessages.count == 0 {
                    ConversationViewModel.shared.fetchSavedMessages()
                }
                
                withAnimation {
                    ConversationViewModel.shared.showSavedPosts = true
                }
            } label: {
                HStack(alignment: .center) {
                    HStack(spacing: 4) {
                        
                        Image(systemName: "bookmark.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.black)
                            .frame(width: 36, height: 20)
                            .padding(.leading, 8)
                        
                        Text("View saved messages")
                            .lineLimit(1)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(.systemGray2))
                        .frame(width: 40, height: 20)
                        .padding(.trailing, 2)
                }
                .padding(.vertical)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.leading)
        .padding(.bottom)
        .shadow(color: Color(.init(white: 0, alpha: 0.2)), radius: 16, x: 0, y: 8)
    }
}


struct SavedPostsOptionsView: View {
    
    
    @StateObject var cameraViewModel = CameraViewModel.shared
    @StateObject var viewModel = ConversationViewModel.shared
    
    @State var audioRecorder = AudioRecorder()
    @State var audioProgress = 0.0
    @State var isRecordingAudio = false
    
    var body: some View {
        
        ZStack {
            
            if !viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard {
                VisualEffectView(effect: UIBlurEffect(style: .regular))
            }
            
            VStack {
                
                ZStack {
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("Saved Messages")
                            .font(.system(size: 18, weight: .medium))
                        
                        Spacer()
                        
                        
                    }
                    
                    HStack {
                        
                        Button {
                            withAnimation {
                                ConversationViewModel.shared.showSavedPosts = false
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 38, height: 38)
                                    .foregroundColor(Color(white: 0, opacity: 0.0))
                                
                                Image(systemName: "chevron.backward")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.black)
                                    .frame(width: 22, height: 22)
                                    .padding(.trailing, 3)
                                
                            }.padding(.horizontal, 20)
                        }
                        
                        
                        Spacer()
                        
                    }
                }
                .frame(width: SCREEN_WIDTH, height: 70)
                .padding(.bottom, BOTTOM_PADDING)
                .padding(.horizontal, 14)
                .transition(.opacity)
            }
        }
        
        .frame(width: SCREEN_WIDTH, height: BOTTOM_PADDING + 70)
        .background(!viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard ? Color(white: 1, opacity: 0.7) : Color.clear)
        
    }
}
