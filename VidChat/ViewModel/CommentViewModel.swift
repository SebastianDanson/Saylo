//
//  CommentViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import SwiftUI
import Firebase

class CommentViewModel: ObservableObject {
    private let post: Post
    @Published var comments = [Comment]()
    
    init(post: Post) {
        self.post = post
        fetchCommens()
    }
    
    func uploadComment(withText commentText: String) {
        guard let user = AuthViewModel.shared.currentUser, let postId = post.id else {return}
        
        let data = ["username": user.username,
                    "profileImageUrl":user.profileImageUrl,
                    "uid":user.id ?? "",
                    "timestamp":Timestamp(date: Date()),
                    "postOwnerUid":post.ownerUid,
                    "commentText":commentText] as [String : Any]
        
        COLLECTION_POSTS.document(postId).collection("post-comments").addDocument(data: data) { _ in
            NotificationsViewModel.uploadNotification(toUid: self.post.ownerUid, type: .comment, post: self.post)
            
        }
    }
    
    func fetchCommens() {
        guard let postId = post.id else {return}
        
        let query = COLLECTION_POSTS.document(postId).collection("post-comments")
            .order(by: "timestamp", descending: true)
        
        query.addSnapshotListener { snapshot, _ in
            guard let addedDocs = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            self.comments.append(contentsOf: addedDocs.compactMap({ try? $0.document.data(as: Comment.self) }))
        }
    }
}
