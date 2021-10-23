//
//  MakeCallViewModel.swift
//  VidChat
//
//  Created by Student on 2021-10-23.
//

import Foundation


class MakeCallViewModel: ObservableObject {
    
    @Published var users = [User]()
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        COLLECTION_USERS.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            snapshot?.documents.forEach({ snapshot in
                self.users.append(User(dictionary: snapshot.data(), id: snapshot.documentID))
            })
        }
    }
}
