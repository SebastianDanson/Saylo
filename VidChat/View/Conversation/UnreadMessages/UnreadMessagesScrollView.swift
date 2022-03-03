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
        
        ZStack(alignment: .bottom) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 4) {
                    
                    ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, message in
                        
                        Button {
                            viewModel.index = i
                        } label: {
                            
                            ZStack {
                                
                                
                                ZStack {
                                    
                                    if i == viewModel.index {
                                        
                                        //                                            Circle().stroke(Color.mainBlue, lineWidth: 2)
                                        //                                                .frame(width: 64, height: 64)
                                        //                                                .transition(.opacity)
                                        
                                        
                                    }
                                    
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
                                                            .clipped()
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
                                                        .clipped()
                                                } else if let image = viewModel.messages[i].image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                                        .cornerRadius(6)
                                                        .clipped()
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: SCREEN_WIDTH)
        }
    }
    
    private func createVideoThumbnail(from url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
        
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


