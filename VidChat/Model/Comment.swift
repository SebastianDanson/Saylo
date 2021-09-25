//
//  Comment.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import FirebaseFirestoreSwift
import Firebase

struct Comment: Identifiable, Decodable {
    let username: String
    let profileImageUrl: String
    let timestamp: Timestamp
    let uid: String
    let commentText: String
    let postOwnerUid: String
    
    @DocumentID var id: String?
}

