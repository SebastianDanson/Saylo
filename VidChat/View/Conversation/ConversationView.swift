//
//  ChatView.swift
//  Saylo
//
//  Created by Student on 2021-10-07.
//

import SwiftUI
import Combine
import AVKit
import Kingfisher

struct ConversationView: View {
    
    @StateObject var viewModel = ConversationViewModel.shared

    @State private var dragOffset = CGSize.zero
    
    private var isFirstLoad = true
    
    var body: some View {
        
        
        ZStack {
            
            
            VStack(spacing: 0) {
                
                ZStack {
                    
                    if viewModel.isPlaying {
                        
                        VStack {
                            
                            Rectangle()
                                .frame(width: SCREEN_WIDTH, height: TOP_PADDING)
                                .foregroundColor(.systemWhite)
                            
                            Spacer()
                        }.zIndex(5)
                    }
                    
                    //Feed
                    //                LazyVStack(spacing: 12) {
                    
                    if !viewModel.showSavedPosts {
                        
                        ConversationFeedView(messages: $viewModel.messages)
                            .overlay(
                                
                                VStack {
                                    if viewModel.messages.count == 0 || (viewModel.messages.count == 1 && viewModel.messages[0].type == .NewChat),
                                       
                                        let chat = viewModel.chat {
                                        
                                        Spacer()
                                        
                                        NoMessagesView(chat: chat).frame(width: SCREEN_WIDTH, height: 200)
                                        
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        
                                    }
                                }.background(Color.systemWhite)
                            )
                    }
                    
                    //Camera
                    if viewModel.showCamera {
                        
                        MainViewModel.shared.cameraView
                            .ignoresSafeArea()
                            .onDisappear {
                                    
                                    DispatchQueue.main.async {
                                        viewModel.currentPlayer?.pause()
                                    }
                                
                            }
                        //                            .transition(.move(edge: .bottom))
                    }
                    
//                    if showSettings {
//                        Button {
//                            withAnimation(.linear(duration: 0.1)) {
//                                showSettings = false
//                            }
//                        } label: {
//                            Rectangle()
//                                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//                                .foregroundColor(.clear)
//                        }
//                    }
                }
                
                if viewModel.showPhotos {
                    VStack {
                        
                        HStack {
                            
                            Button {
                                
                                withAnimation {
                                    viewModel.showPhotos = false
                                }
                                
                            } label: {
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.systemBlack)
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 2)
                                    .padding(.top, 8)
                            }
                            
                            Spacer()
                        }
                        
                    }
                    
                }
                
                
//                if viewModel.showKeyboard {
//                    KeyboardView(text: $text)
//                }
                
                
            }
//            .overlay(
//                ZStack {
//
//                    if !viewModel.showSavedPosts {
//
//                        VStack {
//
////                            if !viewModel.showCamera {
////                                ChatOptions(showSettings: $showSettings)
////                            }
//
//                            Spacer()
//
//                            if !viewModel.showKeyboard {
//                                OptionsView()
//                            }
//                        }
//                    }
//                }
//                ,alignment: .bottom)
            
//            if viewModel.showConversationPlayer {
//                ConversationPlayerView()
//                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .move(edge: .bottom)))
//                    .zIndex(6)
//                    .ignoresSafeArea()
//            }
            
            if viewModel.showImageDetailView {
                ImageDetailView()
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .move(edge: .bottom)))
                    .zIndex(6)
            }
            
            if viewModel.showSavedPosts {
                
                ConversationFeedView(messages: $viewModel.savedMessages)
                    .background(Color.black)
                    .overlay(
                        
                        VStack {
                            
                            Spacer()
                            
                            
                            if viewModel.noSavedMessages {
                                NoSavedMessagesView()
                                    .frame(width: SCREEN_WIDTH, height: 200)
                            }
                            
                            Spacer()
                            
                            SavedPostsOptionsView()
                        }
                        , alignment: .center)
                
                    .transition(.move(edge: .bottom))
                    .zIndex(6)
            }
        }
        .background(Color.systemWhite)
        .edgesIgnoringSafeArea(viewModel.showKeyboard ? .top : .all)
        .onDisappear {
            viewModel.players.forEach({$0.player.pause()})
            viewModel.currentPlayer?.pause()

//            if !showSettings {
//                viewModel.removeChat()
//            }
            
            //Ensure that this is true once they have signed up
            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
            defaults?.set(true, forKey: "hasCompletedSignUp")
        }
    }
}



struct OptionsView: View {
    
    
    @StateObject var cameraViewModel = MainViewModel.shared
    @StateObject var viewModel = ConversationViewModel.shared
    
    @State var audioRecorder = AudioRecorder()
    
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
                                
                                if !viewModel.isRecordingAudio {
                                    
                                    //Camera button
                                    Button(action: {
                                        
                                        withAnimation(.linear(duration: 0.15)) {
                                            cameraViewModel.isShowingPhotoCamera = true
                                            cameraViewModel.startRunning()
                                            viewModel.showCamera = true
                                            viewModel.pauseVideos()
                                        }
                                        
                                    }, label: {
                                        ActionView(image: Image(systemName: "camera.fill"), imageDimension: 30)
                                    }).transition(.scale)
                                }
                                
                                if !viewModel.isRecordingAudio {
                                    
                                    Button(action: {
                                        
//                                        viewModel.photoBaseHeight = viewModel.chatId.isEmpty ? PHOTO_PICKER_SMALL_HEIGHT : PHOTO_PICKER_BASE_HEIGHT
                                        
                                        withAnimation(.linear(duration: 0.15)) {
                                            
                                            viewModel.showPhotos = true
                                            
                                            if viewModel.chatId.isEmpty {
                                                ConversationGridViewModel.shared.isSelectingChats = true
                                            }
                                        }
                                        
                                    }, label: {
                                        ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 31)
                                    }).transition(.scale)
                                    
                                    //Photos button
                                    
                                }
                            }
                            
                            if !viewModel.isRecordingAudio {
                                //Video record circle
                                Button(action: {
                                    
                                    cameraViewModel.handleTap()
                                    viewModel.showCamera = true
                                    viewModel.pauseVideos()
                                    
                                }, label: {
                                    RecordButton().padding(.leading, 15).padding(.trailing, 12)
                                }).transition(.scale)
                            }
                            
                            if !viewModel.showCamera {
                                
                                //Mic button
                                Button(action: {
                                    
                                    withAnimation {
                                        
                                        if !viewModel.isRecordingAudio || (viewModel.chatId.isEmpty && viewModel.showAudio && !audioRecorder.recording) {
                                            viewModel.pauseVideos()
                                            viewModel.audioProgress = 1.0
                                            viewModel.showAudio = true
                                            audioRecorder.startRecording()
                                        } else {
                                            viewModel.audioProgress = 0.0
                                            
                                            if !viewModel.showAudio {
                                                audioRecorder.audioPlayer.isPlaying ?
                                                audioRecorder.pauseRecording() : audioRecorder.playRecording()
                                            } else {
                                                audioRecorder.stopRecording()
                                            }
                                            
                                            viewModel.showAudio = false
                                            
                                            if viewModel.chatId.isEmpty {
                                                ConversationGridViewModel.shared.isSelectingChats = true
                                            }
                                        }
                                        
                                        viewModel.isRecordingAudio = true
                                    }
                                }, label: {
                                    
                                    ActionView(image: Image(systemName: viewModel.showAudio || !viewModel.isRecordingAudio ? "waveform" :
                                                                cameraViewModel.isPlaying ?
                                                            "pause.circle.fill" : "play.circle.fill"),
                                               imageDimension: viewModel.showAudio || !viewModel.isRecordingAudio ? 30 : 60, isActive: $viewModel.isRecordingAudio, isAudio: true)
                                        .foregroundColor(viewModel.isRecordingAudio ? Color(.systemRed) : Color(.systemGray))
                                        .overlay(
                                            ZStack {
                                                // if isRecordingAudio {
                                                Circle()
                                                    .trim(from: 0.0, to: CGFloat(min(viewModel.audioProgress, 1.0)))
                                                    .stroke(Color(.systemRed), style: StrokeStyle(lineWidth: 5,
                                                                                                  lineCap: .round,
                                                                                                  lineJoin: .round))
                                                    .animation(.linear(duration: viewModel.audioProgress == 0 ? 0 : Double(MAX_VIDEO_LENGTH)),
                                                               value: viewModel.audioProgress)
                                                    .frame(width: 48, height: 48)
                                                    .rotationEffect(Angle(degrees: 270))
                                                // }
                                            }
                                        )
                                })
                                
                                if !viewModel.isRecordingAudio {
                                    //Aa button
                                    Button(action: {
                                        withAnimation {
                                            viewModel.showKeyboard = true
                                            
                                            if viewModel.chatId.isEmpty {
                                                ConversationGridViewModel.shared.isSelectingChats = true
                                            }
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
                .padding(.bottom, viewModel.showCamera ? (SCREEN_RATIO > 2 ? 200 + BOTTOM_PADDING : 96 + BOTTOM_PADDING) : BOTTOM_PADDING)
                .padding(.horizontal, 14)
                .overlay(AudioOptions(audioRecorder: $audioRecorder))
                .transition(.opacity)
                
            }
        }
        .frame(width: SCREEN_WIDTH, height: BOTTOM_PADDING + 70)
        .background(!viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard ? (viewModel.isPlaying ? .systemWhite : .point7AlphaSystemWhite) : Color.clear)
        
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView()
        visualEffectView.subviews.forEach({ if $0.backgroundColor != nil { $0.backgroundColor = .clear}})
        return visualEffectView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
        uiView.subviews.forEach({ if $0.backgroundColor != nil { $0.backgroundColor = .clear}})
    }
}

/* The button that records videos and voice */

struct RecordButton: View {
    
    @StateObject var viewModel = MainViewModel.shared
    let mainDimension: CGFloat = IS_SMALL_WIDTH ? 56 : (IS_SMALL_PHONE ? 60 : 62)
    
    var body: some View {
        
        Circle()
            .stroke(.white, style: StrokeStyle(lineWidth: viewModel.isRecording ? 5.0 : 4.5 ))
            .scaledToFit()
            .background(
                
                VStack {
                    
                    if viewModel.isRecording {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: IS_SMALL_PHONE ? (IS_SMALL_WIDTH ? 23 : 27) : 30,
                                   height: IS_SMALL_PHONE ? (IS_SMALL_WIDTH ? 23 : 27) : 30)
                            .foregroundColor(Color(.systemRed))
                            .transition(.scale)
                    } else {
                        Blur(style: .light)
                            .foregroundColor(.clear)
                            .frame(width: mainDimension, height: mainDimension)
                            .clipShape(Circle())

//                            .opacity(0.5)
                    } 
                }
            ).frame(width: viewModel.isShowingPhotoCamera ?  mainDimension + 2 : mainDimension,
                    height: viewModel.isShowingPhotoCamera ? mainDimension + 2 : mainDimension)
            .padding(.horizontal, 5)
    }
}

/* The top right buttons */

struct ChatOptions: View {
    
    @Environment(\.presentationMode) var mode
    @Binding var showSettings: Bool
    
    @StateObject var viewModel = ConversationViewModel.shared
    @StateObject var cameraViewModel = MainViewModel.shared
    
    private let topPadding = UIApplication.shared.windows[0].safeAreaInsets.top
    
    let width: CGFloat = 36
    
    var body: some View {
        
        VStack {
            HStack(spacing: 0) {
                
                Button {
                    mode.wrappedValue.dismiss()
                    viewModel.removeChat()
                } label: {
                    
                    ZStack {
                        Circle()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.point3AlphaSystemBlack)
                        
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .font(Font.title.weight(.semibold))
                            .foregroundColor(.iconSystemWhite)
                            .frame(width: 18, height: 18)
                            .padding(.trailing, 3)
                        
                    }
                }
                
                Spacer()
                                
                if viewModel.chat?.chatMembers.count ?? 1 > 1 {
                    Button {
                        guard let chat = viewModel.chat else { return }
//                        MakeCallViewModel.shared.createNewOutgoingCall(toChat: chat)
                    } label: {
                        
                        ZStack {
                            Circle()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.point3AlphaSystemBlack)
                            
                            Image(systemName: "phone.fill")
                                .resizable()
                                .scaledToFit()
                                .font(Font.title.weight(.ultraLight))
                                .foregroundColor(.iconSystemWhite)
                                .frame(width: 18, height: 18)
                            
                        }.padding(.trailing, 12)
                    }
                }
                
                if let chat = viewModel.chat, !chat.isTeamSaylo {
                    
                    Button {
                        withAnimation(.linear(duration: 0.1)) {
                            showSettings.toggle()
                        }
                    } label: {
                        
                        ChatImageCircle(chat: chat, diameter: width)
                            .padding(.vertical, 10)
                    }
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.top, topPadding + 4)
        
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
        LinearGradient(gradient: Gradient(colors: [isAudio && ConversationViewModel.shared.showAudio ? Color(.systemRed) : .bottomGray, isAudio && ConversationViewModel.shared.showAudio ? Color(.systemRed) : .topGray]), startPoint: .bottom, endPoint: .top)
            .mask(image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: imageDimension, height: imageDimension)
                    .aspectRatio(contentMode: .fit))
    }
}


struct AudioOptions: View {
    
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    @StateObject var viewModel = ConversationViewModel.shared
    @StateObject var conversationGridViewModel = ConversationGridViewModel.shared
    
    @Binding var audioRecorder: AudioRecorder
    
    var body: some View {
        HStack{
            
            if viewModel.isRecordingAudio {
                
                Button {
                    
                    audioRecorder.stopPlayback()
                    
                    withAnimation {
                        viewModel.isRecordingAudio = false
                    }
                    
                    audioRecorder.stopRecording()
                    viewModel.audioProgress = 0.0
                    viewModel.showAudio = false
                    ConversationGridViewModel.shared.stopSelectingChats()
                    
                } label: {
                    
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color(.systemGray))
                        .padding(32)
                    
                }.transition(.move(edge: .leading))
            }
            
            Spacer()
            
            if !viewModel.showAudio && viewModel.isRecordingAudio {
                
                Button {
                    audioRecorder.sendRecording()
                    audioRecorder.stopPlayback()
                    if ConversationViewModel.shared.chatId.isEmpty {
                        viewModel.showAudio = true
                    } else {
                        withAnimation {
                            viewModel.isRecordingAudio = false
                        }
                    }
                    
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.mainBlue)
                        .opacity(canSend() ? 1 : 0.3)
                        .padding(32)
                }.transition(.move(edge: .trailing))
                    .disabled(!canSend())
            }
        }.padding(.bottom, bottomPadding)
    }
    
    func canSend() -> Bool {
        
        if conversationGridViewModel.isSelectingChats {
            return conversationGridViewModel.selectedChats.count > 0
        }
        
        return true
    }
}


//struct KeyboardView: View {
//    
//    @StateObject var viewModel = ConversationViewModel.shared
//    @Binding var text: String
//    
//    let authViewModel = AuthViewModel.shared
//    
//    var body: some View {
//        
//        HStack(alignment: .bottom) {
//            
//            Button {
//                
//                UIApplication.shared.endEditing()
//                
//                withAnimation {
//                    viewModel.showKeyboard = false
//                    ConversationGridViewModel.shared.stopSelectingChats()
//                }
//                
//            } label: {
//                
//                Image(systemName: "xmark.circle.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 32, height: 32)
//                    .foregroundColor(Color.bottomGray)
//                    .transition(.move(edge: .trailing))
//                
//                
//            }
//            .padding(.leading, 16)
//            .padding(.bottom, 8)
//            
//            MultilineTextField("Message...",text: $text, fontSize: 28, returnKey: .send) {
//                
//            }
//            .padding(.vertical, 5)
//            .padding(.horizontal, 3)
//            
//            Spacer()
//            
//            
//            Button {
//                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                    
//                    withAnimation(.linear(duration: 0.15)) {
//                        
//                        viewModel.sendMessage(text: text, type: .Text)
//                        text = ""
//                    }
//                }
//            } label: {
//                
//                Image(systemName: "arrow.up.circle.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 32, height: 32)
//                    .foregroundColor(Color.mainBlue)
//                    .opacity(getIsSendButtonEnabled() ? 1 : 0.3)
//                    .transition(.move(edge: .trailing))
//                    .disabled(!getIsSendButtonEnabled())
//                
//            }
//            .padding(.trailing, 16)
//            .padding(.bottom, 8)
//        }
//    }
//    
//    func getIsSendButtonEnabled() -> Bool {
//        if ConversationViewModel.shared.chatId.isEmpty {
//            return ConversationGridViewModel.shared.selectedChats.count > 0 && !text.isEmpty
//        }
//        
//        return !text.isEmpty
//    }
//}




struct SavedPostsOptionsView: View {
    
    
    @StateObject var cameraViewModel = MainViewModel.shared
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
                                    .foregroundColor(.systemWhite)
                                
                                Image(systemName: "chevron.backward")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.systemBlack)
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
        .background(!viewModel.showCamera && !viewModel.showPhotos && !viewModel.showKeyboard ? .point7AlphaSystemWhite : Color.clear)
        
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
