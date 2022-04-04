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
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if viewModel.messages.count > 0 {
                
                if IS_SMALL_PHONE {
                    Color.init(white: 0, opacity: 0.5)
                        .frame(width: SCREEN_WIDTH, height: MINI_MESSAGE_HEIGHT)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { reader in
                        
                        HStack(spacing: 3) {
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, message in
                                
                                Button {
                                    if ConversationViewModel.shared.index == i, MainViewModel.shared.selectedView == .Saylo {
                                        viewModel.toggleIsPlaying()
                                    } else {
                                        viewModel.showMessage(atIndex: i)
                                        viewModel.selectedMessageIndexes.append(i)
                                    }
                                } label: {
                                    
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
                                                            } else if let image = createVideoThumbnail(from: url) {
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
                                                                .font(.system(size: 10, weight: .bold))
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
                                                
                                                if let chat = viewModel.chat, i > chat.lastReadMessageIndex && !viewModel.selectedMessageIndexes.contains(i) && !viewModel.messages[i].isFromCurrentUser {
                                                    
                                                    Text("New")
                                                        .font(.system(size: 9, weight: .medium, design: .rounded))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 4)
                                                        .padding(.vertical, 1)
                                                        .background(Color.mainBlue)
                                                    //                                                .border(Color.white, width: 2)
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
                                            reader.scrollTo(ConversationViewModel.shared.messages[ConversationViewModel.shared.messages.count - 1].id, anchor: .trailing)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            } else {
                                        
                    VStack(spacing: 0) {
                        
                        Text("Record a Saylo for \(viewModel.chat?.name ?? "")")
                            .foregroundColor(.white)
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .padding(.bottom, 2)
                        
                        Text("Saylo's dissappear after 24h")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .padding(.bottom, IS_SMALL_PHONE ? 8 : 6)
                    }
                    .frame(width: IS_SMALL_PHONE ? SCREEN_WIDTH : SCREEN_WIDTH - 12, height: IS_SMALL_PHONE ? MINI_MESSAGE_HEIGHT : MINI_MESSAGE_HEIGHT - 8)
                    .background(Color(white: 0.1, opacity: IS_SMALL_PHONE ? 0.6 : 1))
                    .cornerRadius(8, corners: IS_SMALL_PHONE ? [.topLeft, .topRight] : .allCorners)
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
            print("ERRROR: \(url)"  + error.localizedDescription)
            ImageCache.getImageCache().set(forKey: url.absoluteString, image: UIImage(systemName: "heart")!)
            return nil
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
