//
//  FeedCell.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI
import Kingfisher

struct FeedCell: View {
    @ObservedObject var viewModel: FeedCellViewModel
    
    init(viewModel: FeedCellViewModel) {
        self.viewModel = viewModel
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            
            //user info
            HStack {
                KFImage(URL(string: viewModel.post.ownerImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipped()
                    .cornerRadius(18)
                
                Text(viewModel.post.ownerUsername)
                    .font(.system(size: 14, weight: .semibold))
            } .padding([.leading, .bottom], 8)
            
            // post image
            KFImage(URL(string: viewModel.post.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 440)
                .clipped()
            
            
            // action buttons
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.post.didLike ?? false ? viewModel.unlike() : viewModel.like()
                }, label: {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .font(.system(size: 20))
                            .clipped()
                })
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    NavigationLink(
                        destination: CommentsView(post: viewModel.post),
                        label: {
                            Image(systemName: "bubble.right")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .font(.system(size: 20))
                                .clipped()
                                .padding(4)
                        })
                })
                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Image(systemName: "paperplane")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .font(.system(size: 20))
                            .clipped()
                            .padding(4)
                })
            }
            .foregroundColor(.black)
            .padding(.leading, 4)
            
            // caption
            Text("\(viewModel.post.likes) likes")
                .font(.system(size: 14, weight: .semibold))
                .padding(.leading, 8)
                .padding(.bottom, 2)
            
            HStack {
                Text("\(viewModel.post.ownerUsername)").font(.system(size: 14, weight: .semibold)) + Text(" \(viewModel.post.caption)")
            }.padding(.horizontal, 8)
            
            Text(viewModel.timestampString)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding([.leading, .top], 4)
            
        }
    }
}

