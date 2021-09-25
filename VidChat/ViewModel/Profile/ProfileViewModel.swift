//
//  ProfileViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    var user: User
    
    init(user: User) {
        self.user = user
        checkIfUserIsFollowed()
    }
    
    func follow() {
        guard let uid = user.id else {return}
        UserService.follow(uid: uid) { _ in
            NotificationsViewModel.uploadNotification(toUid: uid, type: .follow)
            self.user.isFollowed = true
        }
    }
    
    func unfollow() {
        guard let uid = user.id else {return}
        UserService.unfollow(uid: uid) { _ in
            self.user.isFollowed = false
        }
    }
    
    func checkIfUserIsFollowed() {
        guard let uid = user.id, !user.isCurrentUser else {return}
        UserService.checkIfUserIsFollowed(uid: uid) { isFollowed in
            self.user.isFollowed = isFollowed
        }
    }
    
    func fetchUserStats() {
        guard let uid = user.id else {return}
        
        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
            guard let following = snapshot?.documents.count else {return}
            
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
                guard let followers = snapshot?.documents.count else {return}
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
                    guard let posts = snapshot?.documents.count else {return}

                    self.user.stats = UserState(following: following, posts: posts, followers: followers)
                }
            }
        }
    }
}
