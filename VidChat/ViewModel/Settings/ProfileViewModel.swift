//
//  ProfileViewModel.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func follow() {
//        UserService.follow(uid: user.id) { _ in
//            NotificationsViewModel.uploadNotification(toUid: uid, type: .follow)
//            self.user.isFollowed = true
//        }
    }
    
    func unfollow() {
//        UserService.unfollow(uid: user.id) { _ in
//            self.user.isFollowed = false
//        }
    }
}
