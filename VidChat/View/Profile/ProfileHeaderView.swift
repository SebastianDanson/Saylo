//
//  ProfileHeaderView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        Text("Profile Header View")
//        VStack(alignment: .leading) {
//            HStack {
//                KFImage(URL(string: viewModel.user.profileImageUrl))
//                    .resizable()
//                    .frame(width: 80, height: 80)
//                    .scaledToFill()
//                    .clipShape(Circle())
//                    .padding(.leading)
//
//                Spacer()
//
//
//                HStack(alignment: .center, spacing: 16) {
//                    if let stats = viewModel.user.stats {
//                        UserStatView(value: stats.posts, title: "Post")
//                        UserStatView(value: stats.followers, title: "Followers")
//                        UserStatView(value: stats.following, title: "Following")
//                    }
//                }.padding(.trailing, 32)
//            }
//
//            Text(viewModel.user.fullName)
//                .font(.system(size: 15, weight: .semibold))
//                .padding([.leading, .top])
//
//            Text(viewModel.user.username)
//                .font((.system(size: 15)))
//                .padding(.leading)
//                .padding(.top, 1)
//
//            HStack {
//                Spacer()
//
//                ProfileActionButton(viewModel: viewModel)
//
//                Spacer()
//            }.padding(.top)
//        }
    }
}

