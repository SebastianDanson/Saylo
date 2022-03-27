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
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            if viewModel.messages.count > 0 {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    ScrollViewReader { reader in
                        
                        HStack(spacing: 4) {
                            
                            ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, message in
                                
                                Button {
                                    if viewModel.index == i {
                                        viewModel.toggleIsPlaying()
                                    } else {
                                        viewModel.showMessage(atIndex: i)
                                    }
                                } label: {
                                    
                                    ZStack {
                                        
                                        ZStack {
                                            
                                            ZStack {
                                                
                                                if i < viewModel.messages.count {
                                                    
                                                    if viewModel.isPlayable(index: i), let urlString = viewModel.messages[i].url, let url = URL(string: urlString) {
                                                        
                                                        
                                                        if viewModel.messages[i].type == .Video {
                                                            
                                                            if let image = createVideoThumbnail(from: url) {
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
                                                        
                                                        
                                                    } else if viewModel.messages[i].type == .Text, let text = viewModel.messages[i].text {
                                                        
                                                        ZStack {
                                                            
                                                            Text(text)
                                                                .foregroundColor(.white)
                                                                .font(.system(size: 10, weight: .bold))
                                                                .padding()
                                                            
                                                        }
                                                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                        .background(Color.alternateMainBlue)
                                                        .cornerRadius(6)
                                                        
                                                        
                                                    } else if viewModel.messages[i].type == .Photo {
                                                        
                                                        if let url = viewModel.messages[i].url {
                                                            KFImage(URL(string: url))
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                                .cornerRadius(6)
                                                        } else if let image = viewModel.messages[i].image {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                                .cornerRadius(6)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if i == viewModel.index {
                                                
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
                                        .onAppear {
                                            reader.scrollTo(viewModel.messages[viewModel.messages.count - 1].id, anchor: .trailing)
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
                            .padding(.bottom, 6)
                    }
                    .frame(width: SCREEN_WIDTH - 12, height: MINI_MESSAGE_HEIGHT - 8)
                    .background(Color(white: 0.1))
                    .cornerRadius(8)
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
            return thumbnail
        }
        catch {
            print(error.localizedDescription)
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

