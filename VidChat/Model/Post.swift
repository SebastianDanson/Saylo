//
//  Post.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import FirebaseFirestoreSwift
import Firebase

struct Post: Identifiable, Decodable {
    let caption: String
    let imageUrl: String
    var likes: Int
    let ownerImageUrl: String
    let ownerUid: String
    let ownerUsername: String
    let timestamp: Timestamp

    @DocumentID var id: String?
    
    var didLike: Bool? = false
}
