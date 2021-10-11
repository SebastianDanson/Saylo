//
//  PostGridViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation

enum PostGridConfiguration {
    case explore, profile(String)
}

class PostGridViewModel: ObservableObject {
    @Published var posts = [User]()
    let config: PostGridConfiguration
    
    init(config: PostGridConfiguration) {
        self.config = config
        fetchPosts(forConfig: config)
    }
    
    func fetchPosts(forConfig config: PostGridConfiguration) {
//        switch config {
//        case .explore:
//            fetchExplorePagePosts()
//        case .profile(let uid):
//            fetchUserPosts(forUid: uid)
//        }
    }
    
    func fetchExplorePagePosts() {
//        COLLECTION_POSTS.getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            self.posts = documents.compactMap({ try? $0.data(as: Post.self) })
//        }
    }
    
    func fetchUserPosts(forUid uid: String) {
//        COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            self.posts = documents.compactMap({ try? $0.data(as: Post.self) })
//        }
    }
}