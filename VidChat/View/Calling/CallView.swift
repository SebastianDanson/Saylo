//
//  CallView.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import SwiftUI
import Kingfisher

struct CallView: View {
    
    @State private var isMuted: Bool = false
    @State private var isFrontFacing: Bool = true
    @State private var showVideo: Bool = true
//    @State private var showCallOptions = true
    
    @StateObject var callsController = CallManager.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                VideoCallView(isMuted: $isMuted, isFrontFacing: $isFrontFacing, showVideo: $showVideo)
//                    .overlay(
//                        ZStack {
//                            if conversationViewModel.joinedCallUsers.count == 1 {
//                                WaitingForUserToJoinCallView()
//                            }
//                        }
//                    )
//                if showCallOptions {
                    CallOptionsView(isMuted: $isMuted, isFrontFacing: $isFrontFacing, showVideo: $showVideo)
//                }
            }
//            .onTapGesture {
//                showCallOptions.toggle()
//            }
            
            if callsController.remoteUserIDs.count == 0, let chat = CallManager.shared.currentChat {
                DialingView(chat: chat)
            }
        }
    }
}


struct CallOptionsView: View {
    
    @State var muteColor: Color = .white
    @State var videoColor: Color = .white
    
    @Binding var isMuted: Bool
    @Binding var isFrontFacing: Bool
    @Binding var showVideo: Bool
    
    @StateObject var callsController = CallManager.shared
    
    var body: some View {
        HStack {
            
            Button {
                showVideo.toggle()
                ConversationViewModel.shared.showVideo.toggle()
                videoColor = ConversationViewModel.shared.showVideo ? .white : Color(.systemRed)
            } label: {
                CameraOptionView(image: Image(systemName: showVideo ? "video.fill" : "video.slash.fill"),
                                   imageDimension: 28, circleDimension: 60, color: $videoColor)
            }
              
            Spacer()
            
            Button {
                isFrontFacing.toggle()
                MainViewModel.shared.cameraView.switchCamera()
            } label: {
                CameraOptionView(image: Image(systemName: "arrow.triangle.2.circlepath.camera.fill"),
                                   imageDimension: 28, circleDimension: 60)
            }

            
            Spacer()
            
            Button {
                isMuted.toggle()
                muteColor = isMuted ? Color(.systemRed) : .white
            } label: {
                CameraOptionView(image: Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill"),
                                   imageDimension: 28, circleDimension: 60, color: $muteColor)
            }
            
            Spacer()
            
            Button {
                
                callsController.endCalling()
                
                withAnimation {
                    ConversationViewModel.shared.showCall = false
                }
            } label: {
                
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color(.systemRed.withAlphaComponent(0.85)))
                    .overlay(
                        Image("x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24),
                        alignment: .center
                    )
            }

        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12 + BOTTOM_PADDING)
    }
}

struct DialingView: View {
    
    let chat: Chat
    
    var body: some View {
        
        VStack(spacing: 2) {
            
            VStack(spacing: 8) {
                
                ChatImageCircle(chat: chat, diameter: 100)
           
                Text("\(chat.name)")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
            }
            
            Text("Calling...")
                .foregroundColor(.white)
                .font(.system(size: 15))
            
        }.padding(.top, SCREEN_HEIGHT / 8)
    }
}


struct WaitingForUserToJoinCallView: View {
    
    let chat = ConversationViewModel.shared.chat
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Spacer()
            
            if let chat = chat {
                
                KFImage(URL(string: chat.profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: SCREEN_WIDTH/3.5, height: SCREEN_WIDTH/3.5)
                    .clipShape(Circle())
                
                Text("Waiting for \(chat.isDm ? chat.name : "chat members") to join the call...")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: SCREEN_WIDTH - 80)
            }
            
            Spacer()
            
        }
    }
}
