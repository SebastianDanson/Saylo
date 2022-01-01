//
//  NewConversationViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//


import SwiftUI

class NewConversationViewModel: ObservableObject {
    
    @Published var isCreatingNewGroup: Bool = false
    @Published var isSearching: Bool = true
    @Published var isTypingName: Bool = false
    @Published var addedUsers = [User]()

    static let shared = NewConversationViewModel()
    
    private init() {}
    
    func handleUserSelected(user: User) {
        
        withAnimation {
            if !addedUsers.contains(where: { $0.id == user.id }) {
                addedUsers.append(user)
            } else {
                addedUsers.removeAll(where: { $0.id == user.id })
            }
        }
    }
    
    func containsUser(user: User) -> Bool {
        addedUsers.contains(where: { $0.id == user.id })
    }
}
