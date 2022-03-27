//
//  CameraOptionViews.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-02-24.
//
import SwiftUI

struct MessageOptions: View {
    
    @Binding var type: MainViewType
    @Binding var isRecording: Bool
    
    var body: some View {
        
        HStack(spacing: 32) {
            
            if !isRecording {
                
                Button {
                    setMessageType(type: .Photo)
                } label: {
                    
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundColor(.white)
                        .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                }
                
                Button {
                    setMessageType(type: .Voice)
                    MainViewModel.shared.handleRecordButtonTapped()
                } label: {
                    Image(systemName: "waveform")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundColor(.white)
                        .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
                    
                }
            }
            
            
            Button {
                setMessageType(type: .Note)
            } label: {
                Image(systemName: "textformat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .foregroundColor(.white)
                    .shadow(color: Color(white: 0, opacity: 0.3), radius: 4, x: 0, y: 4)
            }
            
            //
            //                Button {
            //                    setMessageType(type: .Saylo)
            //                    ConversationViewModel.shared.updateLastVisitedForChat(withId: ConversationViewModel.shared.chatId)
            //                } label: {
            //                    Text("Saylos")
            //                        .foregroundColor(type == .Saylo ? .white : Color(.systemGray5))
            //                        .font(.system(size: type == .Saylo ? 17 : 16, weight: type == .Saylo ? .bold : .semibold, design: .rounded))
            //                        .frame(width: 70)
            //                }
            
            //            }
        }
    }
    
    func setMessageType(type: MainViewType) {
        
        let mainViewModel = MainViewModel.shared
        
        if type != .Photo {
            mainViewModel.photo = nil
        }
        
        if mainViewModel.isRecording {
            mainViewModel.reset()
        }
        
        withAnimation {
            mainViewModel.selectedView = type
        }
    }
}

struct SaveButton: View {
    
    @State var hasSaved = false
    var viewModel = MainViewModel.shared
    
    var body: some View {
        
        Button {
            
            if !hasSaved {
                
                if PhotosViewModel.shared.getHasAccessToPhotos() {
                    
                    viewModel.savePhoto()
                    hasSaved = true
                } else {
                    PhotosViewModel.shared.showNoAccessToPhotosAlert = true
                }
            }
            
        } label: {
            
            ZStack {
                
                Image(systemName: hasSaved ? "checkmark" : "square.and.arrow.down")
                    .resizable()
                    .font(Font.title.weight(.semibold))
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: hasSaved ? 28 : 32, height: hasSaved ? 28 : 32)
            }
            //                        .background(Color(white: 0, opacity: 0.4))
            //                        .clipShape(Circle())
            
            
        }
        .disabled(hasSaved)
        .padding(.leading, 4)
    }
}

struct MediaOptions: View {
    
    @StateObject var viewModel = MainViewModel.shared
    
    @State var hasSaved = false
    
    var body: some View {
        
        VStack {
            
            if viewModel.videoUrl != nil || viewModel.photo != nil {
                
                HStack {
                    
                    // X button
                    Button {
                        //  withAnimation(.linear(duration: 0.15)) {
                        viewModel.reset()
                        //}
                    } label: {
                        CameraOptionView(image: Image("x"), imageDimension: 14, circleDimension: 32)
                            .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        
                        Spacer()
                        
                        
                        
                        if viewModel.videoUrl != nil {
                            
                            Button {
                                
                                //                                viewModel.videoPlayerView = nil
                                viewModel.videoUrl = nil
                                viewModel.isRecording = false
                                viewModel.handleTap()
                                
                            } label: {
                                
                                ZStack {
                                    
                                    Image(systemName: "video.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 34, height: 34)
                                    
                                    
                                }
                                .frame(width: 48, height: 48)
                                //                            .background(Color(white: 0, opacity: 0.4))
                                //                            .clipShape(Circle())
                                .padding(.leading, 2)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 15)
                
                HStack(alignment: .bottom, spacing: 3) {
                    
                    if ConversationViewModel.shared.chat == nil && ConversationViewModel.shared.selectedChat == nil {
                        SuggestedChatsView(chats: ConversationGridViewModel.shared.chats)
                    }
                    
                    Spacer()
                    
                    SendButton()
                        .padding(.trailing, 12)
                }
                .padding(.bottom, getBottomPadding())
            }
        }
    }
    
    func getBottomPadding() -> CGFloat {
        if ConversationViewModel.shared.chat == nil && ConversationViewModel.shared.selectedChat == nil {
            return  SCREEN_RATIO > 2 ? BOTTOM_PADDING + 5 : BOTTOM_PADDING + 20
        } else {
            return  SCREEN_RATIO > 2 ? BOTTOM_PADDING + 28 : BOTTOM_PADDING + 20
        }
    }
}

//struct SendButton: View {
//    
//    var viewModel = MainViewModel.shared
//    
//    var body: some View {
//        
//        Button(action: {
//            
//            withAnimation(.linear(duration: 0.2)) {
//                
//                let conversationVM = ConversationViewModel.shared
//                viewModel.videoPlayerView?.player.pause()
//                
//                if let chat = conversationVM.selectedChat {
//                    conversationVM.sendCameraMessage(chatId: chat.id, chat: chat)
//                    viewModel.reset()
//                    ConversationPlayerViewModel.shared.showNextMessage()
//                } else if conversationVM.chatId.isEmpty {
//                    withAnimation {
//                        ConversationGridViewModel.shared.isSelectingChats = true
//                        ConversationGridViewModel.shared.cameraViewZIndex = 1
//                    }
//                }  else if let chat = conversationVM.chat {
//                    conversationVM.isSending = true
//                    conversationVM.sendCameraMessage(chatId: chat.id, chat: chat)
//                    viewModel.reset()
//                }
//                
//            }
//            
//        }, label: {
//            
//            
//            if ConversationViewModel.shared.chat == nil && ConversationViewModel.shared.selectedChat == nil {
//                
//                VStack(spacing: 2) {
//                    
//                    Image("more")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 32, height: 32)
//                    
//                }
//                .frame(width: 62, height: 62)
//                .background(Color.mainBlue)
//                .clipShape(Circle())
//                
//            } else {
//                HStack(spacing: 8) {
//                    
//                    Text(getSendText())
//                        .foregroundColor(.black)
//                        .font(.system(size: 16, weight: .semibold))
//                    
//                    Image(systemName: "location.north.fill")
//                        .resizable()
//                        .rotationEffect(Angle(degrees: 90))
//                        .foregroundColor(.black)
//                        .frame(width: 18, height: 18)
//                        .scaledToFit()
//                }
//                .padding(.horizontal, 12)
//                .frame(height: 38)
//                .background(Color.mainBlue)
//                .clipShape(Capsule())
//                
//            }
//            
//        })
//        
//    }
//    
//    func getSendText() -> String {
//        let viewModel = ConversationViewModel.shared
//        
//        if let chat = viewModel.selectedChat{
//            return chat.name
//        } else if viewModel.chatId == "" {
//            return "See all"
//        } else {
//            return "Send"
//        }
//    }
//}

struct TakenPhotoOptions: View {
    
    var viewModel = MainViewModel.shared
    
    var body: some View {
        
        
        HStack {
            
            Button {
                viewModel.photo = nil
            } label: {
                
                Image(systemName: "trash.fill")
                    .resizable()
                    .font(Font.title.weight(.medium))
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
            
            SaveButton()
            
        }.frame(width: 240)
    }
}

struct CameraOptions: View {
    
    @StateObject var viewModel = MainViewModel.shared
    @Binding var isFrontFacing: Bool
    
    //height of extra space above and below camera
    let nonCameraHeight = SCREEN_HEIGHT - (SCREEN_WIDTH * 16/9) // Camera aspect ratio is 16/9
    
    var cameraView: CameraView
    
    var body: some View {
        
        VStack {
            
            if viewModel.videoUrl == nil && viewModel.photo == nil {
                
                HStack {
                    
                    // X button
                    
                    Button {
                        //  withAnimation {
                        viewModel.reset()
                        cameraView.cancelRecording()
                        //}
                    } label: {
                        CameraOptionView(image: Image("x"), imageDimension: 14)
                    }
                    
                    Spacer()
                    
                    //Flash toggle button
                    Button {
                        self.viewModel.hasFlash.toggle()
                    } label: {
                        CameraOptionView(image: Image(systemName: viewModel.hasFlash ? "bolt.fill" : "bolt.slash.fill"))
                    }
                    
                }.padding(.vertical, 4)
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    
                    //Switch camera button
                    Button(action: {
                        cameraView.switchCamera()
                        isFrontFacing.toggle()
                    }, label: {
                        CameraOptionView(image: Image(systemName:"arrow.triangle.2.circlepath"), imageDimension: 32, circleDimension: 50)
                    })
                }
            }
        }
        .padding(.top, TOP_PADDING)
        .padding(.bottom, SCREEN_RATIO > 2 ? BOTTOM_PADDING + 100 : BOTTOM_PADDING + 48)
        .padding(.horizontal, 6)
        
    }
}


struct CameraOptionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    var topPadding: CGFloat = 0
    @Binding var color: Color
    
    init(image: Image, imageDimension: CGFloat = 20, circleDimension: CGFloat = 36, color: Binding<Color> = .constant(.white), topPadding: CGFloat = 0) {
        self.image = image
        self.imageDimension = imageDimension
        self.circleDimension = circleDimension
        self._color = color
        self.topPadding = topPadding
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: imageDimension, height: imageDimension)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 20 + topPadding)
            .background(
                Circle()
                    .frame(width: circleDimension, height: circleDimension)
                    .foregroundColor(Color(white: 0, opacity: 0.4))
            )
    }
}
