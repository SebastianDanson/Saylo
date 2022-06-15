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
            if messages.count > 0 || viewModel.currentlyWatchingId != nil || !viewModel.sendingLiveRecordingId.isEmpty {
            
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { reader in
                        
                        HStack(spacing: IS_SMALL_WIDTH ? 3 : 4) {
                            
                            if !viewModel.showSavedPosts {
                                ViewSavedMessagesButton()
                            }

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
                                            
                                            if !viewModel.showSavedPosts {
                                                let profileImages = viewModel.usersLastVisited
                                                    .filter({$0.index == i && $0.id != AuthViewModel.shared.getUserId()})
                                                    .map({$0.profileImage})
                                               
                                                if profileImages.count > 0 {
                                                    LastSeenProfileImageView(profileImages: profileImages)
                                                }
                                            }
                                            
                                        }
                                        ,alignment: .topLeading
                                    )
                                    .onAppear {
                                        if messages.count > 0 {
                                            reader.scrollTo(messages[messages.count - 1].id, anchor: .trailing)
                                        }
                                    }
                                }
                                .overlay(
                                    
                                    ZStack {
//
                                        if i == messages.count - 1 {
                                            MessageSendingView(isSending: $viewModel.isSending, hasSent: $viewModel.hasSent)
                                        }
                                        
                                        SaveView(showAlert: $showAlert, isSaved: messages[i].isSaved, index: i)
//
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
                            
                            LiveUsersView(liveUsers: $viewModel.liveUsers, reader: reader)
                            
                            if !viewModel.sendingLiveRecordingId.isEmpty && viewModel.sendingLiveRecordingId != AuthViewModel.shared.getUserId() {
                                LoadingVideoView(reader: reader)
                            }
                        }
                    }
                }
            } else {
                
                if !viewModel.showSavedPosts {
                    
                    HStack {
   
                        VStack(spacing: 4) {
                            
                            Text("Saylo's dissapear after 48h")
                                .foregroundColor(.white)
                                .font(.system(size: IS_SE ? 18 : (IS_SMALL_WIDTH ? 20 : 22), weight: .semibold, design: .rounded))
                                .padding(.bottom, 2)
                            
                            HStack(spacing: 4) {
                                
                                let size: CGFloat = IS_SE ? 14 : (IS_SMALL_WIDTH ? 15 : 16)
                                
                                Text("Tap")
                                    .foregroundColor(.white)
                                    .font(.system(size: size, weight: .regular, design: .rounded))
                                
                                Image(systemName: "bookmark")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: size, height: size)
                                
                                Text("on Saylo's you want to save")
                                    .foregroundColor(.white)
                                    .font(.system(size: IS_SE ? 14 : (IS_SMALL_WIDTH ? 15 : 16), weight: .regular, design: .rounded))
                                
                            }
                            .padding(.bottom, IS_SMALL_PHONE ? (IS_SMALL_WIDTH ? 2 : 8) : 6)
                            
                        }
                        .frame(width: SCREEN_WIDTH - 12, height: MINI_MESSAGE_HEIGHT - 8)
                        .background(Color(white: 0.1, opacity: 1))
                        .cornerRadius(8, corners: .allCorners)
                        .overlay(ViewSavedMessagesButtonSmall(), alignment: .topTrailing)
                    }
                }
            }
        }
        .frame(width: SCREEN_WIDTH)
        .onDisappear {
            viewModel.isSending = false
            viewModel.hasSent = false
        }
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







//struct SaveViewPaused: View {
//
//    @Binding var isSaved: Bool
//    @Binding var showAlert: Bool
//    let index: Int
//
//    init(showAlert: Binding<Bool>, isSaved: Binding<Bool>, index: Int) {
//        self._isSaved = isSaved
//        self._showAlert = showAlert
//        self.index = index
//    }
//
//    var body: some View {
//
//        VStack {
//
//            Button {
//
//
//                withAnimation {
//
//                    if !isSaved {
//                        MainViewModel.shared.isSaving = true
//                        ConversationViewModel.shared.updateIsSaved(atIndex: index)
//                    } else {
//                        showAlert = true
//                    }
//                }
//            } label: {
//
//                //                ZStack {
//                //
//                //                    Color.fadedBlack
//                //
//                //                    VStack(spacing: 3) {
//                //
//                //                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
//                //                            .resizable()
//                //                            .scaledToFit()
//                //                            .frame(width: 26, height: 26)
//                //                            .foregroundColor(Color(.white))
//                //
//                //                        Text(self.isSaved ? "Unsave" : "Save")
//                //                            .foregroundColor(.white)
//                //                            .font(Font.system(size: 12, weight: .semibold, design: .rounded))
//                //
//                //                    }
//                //
//                //                }
//                //                .frame(width: 64, height: 64)
//                //                .clipShape(Circle())
//                //                .padding(4)
//
//            }
//        }
//    }
//}
















