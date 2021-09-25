//
//  SearchViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var posts = [Post]()

    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        COLLECTION_USERS.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {return}
            self.users = documents.compactMap({ try? $0.data(as: User.self) })
        }
    }
    
    func filteredUsers(_ query: String) -> [User] {
        let lowercasedQuery = query.lowercased()
        return users.filter({ $0.fullName.lowercased().contains(lowercasedQuery) || $0.username.contains(lowercasedQuery) })
    }
}
