//
//  NotificationsCell.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct NotificationsCell: View {
    
    @ObservedObject var viewModel: NotificationCellViewModel
    
    var isFollowed: Bool { return viewModel.notification.isFollowed ?? false }
    
    var body: some View {
        HStack {
            
            if let user = viewModel.notification.user {
                NavigationLink(
                    destination: ProfileView(user: user),
                    label: {
                        KFImage(URL(string: viewModel.notification.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    })
                }
            
            
            Text(viewModel.notification.username).font(.system(size: 14, weight: .semibold)) + Text(" \(viewModel.notification.type.notificationMessage)")
            
            Spacer()
            
            if viewModel.notification.type != .follow {
                if let post = viewModel.notification.post {
                    KFImage(URL(string: post.imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                }
            } else {
                Button(action: {}, label: {
                    Text(isFollowed ? "Following" : "Folllow")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(isFollowed ? Color.white : Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .font(.system(size: 14, weight: .semibold))
                })
            }
        }.padding(.horizontal)
    }
}

