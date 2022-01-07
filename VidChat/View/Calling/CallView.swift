//
//  CallView.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import SwiftUI
import Kingfisher

struct CallView: View {
    
    @State private var isMuted: Bool = false
    @State private var isFrontFacing: Bool = true
    @State private var showVideo: Bool = true
    @State private var showCallOptions = true
    
    @StateObject var callsController = CallManager.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                VideoCallView(isMuted: $isMuted, isFrontFacing: $isFrontFacing, showVideo: $showVideo, showCallOptions: $showCallOptions)
                if showCallOptions {
                    CallOptionsView(isMuted: $isMuted, isFrontFacing: $isFrontFacing, showVideo: $showVideo)
                }
            }.onTapGesture {
                showCallOptions.toggle()
            }
            
            if callsController.remoteUserIDs.count == 0  {
                DialingView(profileImage: CallManager.shared.currentChat?.profileImageUrl ?? "", name: CallManager.shared.currentChat?.name ?? "")
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
            
            CamereraOptionView(image: Image(systemName: showVideo ? "video.fill" : "video.slash.fill"),
                               imageDimension: 28, circleDimension: 60, color: $videoColor)
                .onTapGesture {
                    showVideo.toggle()
                    videoColor = showVideo ? .white : Color(.systemRed)
                }
            
            Spacer()
            
            CamereraOptionView(image: Image(systemName: "arrow.triangle.2.circlepath.camera.fill"),
                               imageDimension: 28, circleDimension: 60)
                .onTapGesture {isFrontFacing.toggle() }
            
            Spacer()
            
            CamereraOptionView(image: Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill"),
                               imageDimension: 28, circleDimension: 60, color: $muteColor)
                .onTapGesture {
                    isMuted.toggle()
                    muteColor = isMuted ? Color(.systemRed) : .white
                }
            
            Spacer()
            
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
                .onTapGesture {
                    callsController.endCalling()
                    withAnimation {
                        ConversationViewModel.shared.showCall = false
                    }
                }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12 + BOTTOM_PADDING)
    }
}

struct DialingView: View {
    
    let profileImage: String
    let name: String
    
    var body: some View {
        VStack(spacing: 2) {
            VStack(spacing: 8) {
                KFImage(URL(string: profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                Text("\(name)")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
            }
            
            Text("Calling...")
                .foregroundColor(.white)
                .font(.system(size: 15))
            
        }.padding(.top, UIScreen.main.bounds.height / 8)
    }
}
