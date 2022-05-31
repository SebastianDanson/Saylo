//
//  UnreadMessagesScrollView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-20.
//

import SwiftUI
import Kingfisher
import AVKit

struct UnreadMessagesScrollView: View {
    
    @ObservedObject var viewModel = ConversationViewModel.shared
    @Binding var selectedView: MainViewType
    @State var thumbnails = [String:UIImage?]()
    @Binding var showAlert: Bool
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            let messages = viewModel.showSavedPosts ? viewModel.savedMessages : viewModel.messages
            
            if messages.count > 0 {
                //
                //                if IS_SMALL_PHONE {
                //                    Color.init(white: 0, opacity: 0.5)
                //                        .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT)
                //                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { reader in
                        
                        HStack(spacing: IS_SMALL_WIDTH ? 3 : 4) {
                            
                            ForEach(Array(messages.enumerated()), id: \.1.id) { i, message in
                                
                                ZStack {
                                    
                                    ZStack {
                                        
                                        ZStack {
                                            
                                            if ConversationViewModel.shared.isPlayable(index: i), let urlString = message.url, let url = URL(string: urlString) {
                                                
                                                if message.type == .Video {
                                                    
                                                    if let image = ImageCache.getImageCache().get(forKey: urlString) {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                            .cornerRadius(6)
                                                    }
                                                    else if let image = createVideoThumbnail(from: url) {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                            .cornerRadius(6)
                                                    }
                                                } else {
                                                    
                                                    VStack {
                                                        Spacer()
                                                        Image(systemName: "mic.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 32, height: 32)
                                                            .foregroundColor(.white)
                                                        Spacer()
                                                    }
                                                    .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                    .background(Color.alternateMainBlue)
                                                    .cornerRadius(6)
                                                }
                                                
                                                
                                            } else if message.type == .Text, let text = message.text {
                                                
                                                ZStack {
                                                    
                                                    Text(text)
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 11, weight: .bold))
                                                        .padding()
                                                    
                                                }
                                                .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                .background(Color.alternateMainBlue)
                                                .cornerRadius(6)
                                                
                                                
                                            } else if message.type == .Photo {
                                                
                                                if let url = message.url {
                                                    KFImage(URL(string: url))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                        .cornerRadius(6)
                                                } else if let image = message.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                        .cornerRadius(6)
                                                }
                                            } else if message.type == .Call {
                                                CallEndedView(isLarge: false)
                                                    .cornerRadius(6)
                                            }
                                        }
                                        
                                        if i == viewModel.index, selectedView == .Saylo {
                                            
                                            ZStack {
                                                Color.init(white: 0, opacity: 0.5)
                                            }
                                            .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                            .cornerRadius(6)
                                            
                                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.white)
                                                .frame(width: 32, height: 32)
                                        }
                                    }
                                    .overlay(
                                        
                                        ZStack {
                                            
                                            if let chat = viewModel.chat, i > chat.lastReadMessageIndex && !viewModel.selectedMessageIndexes.contains(i) && !messages[i].isFromCurrentUser && !viewModel.showSavedPosts {
                                                
                                                Text("New")
                                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 1)
                                                    .background(Color.mainBlue)
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.white, lineWidth: 1)
                                                    )
                                                    .padding(3)
                                            }
                                            
                                        }
                                        ,alignment: .topLeading
                                    )
                                    .onAppear {
                                        reader.scrollTo(messages[messages.count - 1].id, anchor: .trailing)
                                    }
                                }
                                .overlay(
                                    
                                    ZStack {
                                                                                
                                        if i == messages.count - 1 {
                                            MessageSendingView(isSending: $viewModel.isSending, hasSent: $viewModel.hasSent)
                                        }
                                        
                                        
                                        let isSaved = viewModel.showSavedPosts ? $viewModel.savedMessages[i].isSaved : $viewModel.messages[i].isSaved
                                        SaveView(showAlert: $showAlert, isSaved: isSaved, index: i)
                                    }
                                    
                                )
                                .onTapGesture {
                                    
                                    if ConversationViewModel.shared.index == i, MainViewModel.shared.selectedView == .Saylo {
                                        viewModel.toggleIsPlaying()
                                    } else {
                                        viewModel.showMessage(atIndex: i)
                                        viewModel.selectedMessageIndexes.append(i)
                                    }
                                }
                                .onLongPressGesture {
                                    MainViewModel.shared.selectedMessage = message
                                }
                            }
                            
                            //                            if viewModel.liveUsers.count > 0, !viewModel.liveUsers.contains(AuthViewModel.shared.getUserId()) {
                            LiveUsersView(liveUsers: $viewModel.liveUsers, reader: reader)
                            
                            
                            //                            }
                            
                            if !viewModel.sendingLiveRecordingId.isEmpty && viewModel.sendingLiveRecordingId != AuthViewModel.shared.getUserId() {
                                LoadingVideoView()
                            }
                            
                        }
                    }
                }
                
            } else {
                
                if !viewModel.showSavedPosts {
                    
                    VStack(spacing: 2) {
                        
                        Text("Record a Saylo for \(viewModel.chat?.name ?? "")")
                            .foregroundColor(.white)
                            .font(.system(size: IS_SE ? 18 : (IS_SMALL_WIDTH ? 20 : 22), weight: .semibold, design: .rounded))
                            .padding(.bottom, 2)
                        
                        
                        Text("Unsaved Saylo's dissappear after 48h")
                            .foregroundColor(.white)
                            .font(.system(size: IS_SE ? 14 : (IS_SMALL_WIDTH ? 15 : 16), weight: .regular, design: .rounded))
                            .padding(.bottom, IS_SMALL_PHONE ? (IS_SMALL_WIDTH ? 2 : 8) : 6)
                        
                    }
                    .frame(width: SCREEN_WIDTH - 12, height: MINI_MESSAGE_HEIGHT - 8)
                    .background(Color(white: 0.1, opacity: 1))
                    .cornerRadius(8, corners: .allCorners)
                    
                }
            }
            
            
        }
        .frame(width: SCREEN_WIDTH)
    }
    
    
    private func createVideoThumbnail(from url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: MINI_MESSAGE_WIDTH * 3, height: MINI_MESSAGE_HEIGHT * 3)
        
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            ImageCache.getImageCache().set(forKey: url.absoluteString, image: thumbnail)
            return thumbnail
        }
        catch {
            print("ERRRROR: \(url)"  + error.localizedDescription)
            ImageCache.getImageCache().set(forKey: url.absoluteString, image: UIImage(systemName: "exclamationmark.bubble.fill")!)
            return nil
        }
    }
}

struct CallEndedView: View {
    
    let isLarge: Bool
    
    var body: some View {
        
        VStack(spacing: isLarge ? 24 : 8){
            
            Image("video")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: isLarge ? SCREEN_WIDTH/5 : MINI_MESSAGE_WIDTH/3)
                .padding(.leading, isLarge ? 4 : 1)
            
            Text("Ended")
                .foregroundColor(.white)
                .font(Font.system(size: isLarge ? 32 : 16, weight: .semibold, design: .rounded))
            
        }
        .frame(width: isLarge ? SCREEN_WIDTH : MINI_MESSAGE_WIDTH, height: isLarge ? MESSAGE_HEIGHT : MINI_MESSAGE_HEIGHT)
        .background(Color(white: 0.2))
        
    }
}


struct CircularLoadingAnimationView: View {
    
    @State private var isLoading = false
    let dimension: CGFloat
    
    var body: some View {
        ZStack {
            
            //            Circle()
            //                .stroke(Color(.systemGray5), lineWidth: 6)
            //                .frame(width: dimension, height: dimension)
            
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color.green, lineWidth: 6)
                .frame(width: dimension, height: dimension)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() {
                    self.isLoading = true
                }
        }
    }
}

struct SaveView: View {

    @Binding var isSaved: Bool
    @Binding var showAlert: Bool
    let index: Int

    init(showAlert: Binding<Bool>, isSaved: Binding<Bool>, index: Int) {
        self._isSaved = isSaved
        self._showAlert = showAlert
        self.index = index
    }

    var body: some View {

        VStack {

            HStack {

                Spacer()

                Button {

                    if !isSaved {
                        MainViewModel.shared.isSaving = true
                        ConversationViewModel.shared.updateIsSaved(atIndex: index)
                    } else {
                        showAlert = true
                    }
                } label: {

                    ZStack {

                        Color.fadedBlack

                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19, height: 19)
                            .foregroundColor(Color(.white))

                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .padding(4)

                }

            }

            Spacer()
        }
    }
}

struct SaveViewPaused: View {
    
    @Binding var isSaved: Bool
    @Binding var showAlert: Bool
    let index: Int
    
    init(showAlert: Binding<Bool>, isSaved: Binding<Bool>, index: Int) {
        self._isSaved = isSaved
        self._showAlert = showAlert
        self.index = index
    }
    
    var body: some View {
        
        VStack {
            
            Button {
                
                
                withAnimation {
                                        
                    if !isSaved {
                        MainViewModel.shared.isSaving = true
                        ConversationViewModel.shared.updateIsSaved(atIndex: index)
                    } else {
                        showAlert = true
                    }
                }
            } label: {
                
                ZStack {
                    
                    Color.fadedBlack
                    
                    VStack(spacing: 3) {
                        
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(Color(.white))
                        
                        Text(self.isSaved ? "Unsave" : "Save")
                            .foregroundColor(.white)
                            .font(Font.system(size: 12, weight: .semibold, design: .rounded))
                        
                    }
                    
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .padding(4)
                
            }
        }
    }
}

struct SavedPopUp: View {
    
    var body: some View {
        
        ZStack {
            
            Color.fadedBlack
            
            VStack {
                
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                
                Text("Saved")
                    .foregroundColor(.white)
                    .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                
            }
            
        }
        .frame(width: 100, height: 100)
        .cornerRadius(20)
        
    }
}

struct LoadingVideoView: View {
    
    var body: some View {
        
        ZStack {
            
            Color.init(white: 0.1)
            
            CircularLoadingAnimationView(dimension: MINI_MESSAGE_WIDTH / 1.3)
            
        }
        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
        .cornerRadius(6)
        
    }
}


struct LiveUsersView: View {
    
    @Binding var liveUsers: [String]
    var reader: ScrollViewProxy
    
    var body: some View  {
        
        ForEach(Array(liveUsers.enumerated()), id: \.1) { i, id in
            
            if id != AuthViewModel.shared.getUserId(), let chatMember = getChatMember(fromId: id) {
                
                ZStack {
                    
                    Color.init(white: 0.1)
                    
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        KFImage(URL(string: chatMember.profileImage))
                            .resizable()
                            .scaledToFill()
                            .frame(width: MINI_MESSAGE_WIDTH/1.3, height: MINI_MESSAGE_HEIGHT/1.3)
                            .clipShape(Circle())
                        
                        HStack(spacing: 5) {
                            
                            Spacer()
                            
                            Circle()
                                .frame(width: 11, height: 11)
                                .foregroundColor(Color(.systemRed))
                            
                            Text("Live")
                                .foregroundColor(.white)
                                .font(Font.system(size: 14, weight: .semibold))
                            
                            Spacer()
                            
                        }
                        
                        Spacer()
                    }
                }
                .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                .cornerRadius(6)
                .onTapGesture {
                    ConversationViewModel.shared.currentlyWatchingId = id
                    ConversationViewModel.shared.isLive = true
                }
                .onAppear {
                    reader.scrollTo(id, anchor: .trailing)
                }
            }
        }
    }
    
    func getChatMember(fromId id: String) -> ChatMember? {
        
        guard let chat = ConversationViewModel.shared.chat else { return nil }
        return chat.chatMembers.first(where: {$0.id == id})
    }
}

struct MessageSendingView: View {
    
    @Binding var isSending: Bool
    @Binding var hasSent: Bool
    
    
    var body: some View {
        
        ZStack {
            
            //            if i == messages.count - 1 {
            
            
            if hasSent {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                        .foregroundColor(.mainBlue)
                        .opacity(0.9)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: MINI_MESSAGE_WIDTH/3, height: MINI_MESSAGE_WIDTH/3)
                        .foregroundColor(.systemWhite)
                    
                }.transition(.opacity)
                
            }
            
            
            
            if isSending {
                
                VStack {
                    
                    Spacer()
                    
                    ZStack {
                        
                        
                        Button {
                            MediaUploader.uploadTask?.cancel()
                            ConversationViewModel.shared.cancelUpload()
                            isSending = false
                        } label: {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                    .foregroundColor(Color(white: 0, opacity: 0.4))
                                
                                VStack(spacing: 2) {
                                    
                                    Image(systemName: "trash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: MINI_MESSAGE_WIDTH/4, height: MINI_MESSAGE_WIDTH/4)
                                        .foregroundColor(.white)
                                    
                                    Text("Cancel")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .semibold))
                                    
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            ActivityIndicatorRectangle(width: MINI_MESSAGE_WIDTH - 8)
                                .transition(.opacity)
                        }
                        
                    }.padding(.bottom, 10)
                }
            }
        }
    }
}

struct ReplyView: View {
    
    
    let isForTakingVideo: Bool
    
    var body: some View {
        
        ZStack {
            
            if isForTakingVideo == true {
                
                ZStack {
                    
                    
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                    
                }
                .frame(width: 56, height: 56)
                .background(Color.init(white: 0, opacity: 0.4))
                .clipShape(Circle())
            }
        }
    }
}

class ImageCache {
    
    var cache = NSCache<NSString, UIImage>()
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(forKey: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
