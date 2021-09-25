//
//  User.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    let username: String
    let email: String
    let profileImageUrl: String
    let fullName: String
    @DocumentID var id: String?
    var stats: UserState?
    var isFollowed: Bool? = false
    
    var isCurrentUser: Bool { return AuthViewModel.shared.userSession?.uid == id}
}

struct UserState: Decodable {
    var following: Int
    var posts: Int
    var followers: Int
}
