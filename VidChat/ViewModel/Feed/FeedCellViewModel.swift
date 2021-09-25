//
//  FeedCellViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import Foundation
import Firebase

class FeedCellViewModel: ObservableObject {
    @Published var post: Post
    
    init(post: Post) {
        self.post = post
        checkIfUserLikedPost()
    }
    
    var timestampString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: post.timestamp.dateValue(), to: Date()) ?? ""
    }
    
    func like() {
        guard let id = post.id, let uid = AuthViewModel.shared.userSession?.uid else {return}
        COLLECTION_POSTS.document(id)
            .collection("post-likes").document(uid).setData([:]) { _ in
                COLLECTION_USERS.document(uid).collection("user-likes")
                    .document(id).setData([:]) { _ in
                        
                        COLLECTION_POSTS.document(id).updateData(["likes": FieldValue.increment(1.0)])
                        self.post.didLike = true
                        self.post.likes += 1
                        NotificationsViewModel.uploadNotification(toUid: self.post.ownerUid,
                                                                  type: .like, post: self.post)
                    }
            }
    }
    
    func unlike() {
        guard post.likes > 0, let id = post.id, let uid = AuthViewModel.shared.userSession?.uid else {return}
        COLLECTION_POSTS.document(id)
            .collection("post-likes").document(uid).delete { _ in
                COLLECTION_USERS.document(uid).collection("user-likes")
                    .document(id).delete { _ in
                        
                        COLLECTION_POSTS.document(id).updateData(["likes": FieldValue.increment(-1.0)])
                        self.post.didLike = false
                        self.post.likes -= 1
                    }
            }
    }
    
    func checkIfUserLikedPost() {
        guard let id = post.id, let uid = AuthViewModel.shared.userSession?.uid else {return}
        COLLECTION_USERS.document(uid).collection("user-likes").document(id).getDocument { snapshot, _ in
            guard let didLike = snapshot?.exists else { return }
            self.post.didLike = didLike
        }
    }
}
