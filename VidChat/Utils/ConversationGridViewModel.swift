//
//  ConversationGridViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI

class ConversationGridViewModel: ObservableObject {
    
    @Published var isSelectingUsers = false
    @Published var cameraViewZIndex: Double = 3
    @Published var hideFeed = false
    @Published var selectedUsers = [TestUser]()

    static let shared = ConversationGridViewModel()
    
    private init() {}
    
    func removeSelectedUser(withId id: UUID) {
        if let index = selectedUsers.firstIndex(where: {$0.id == id}) {
            withAnimation {
                selectedUsers[index].isSelected = !selectedUsers[index].isSelected
                selectedUsers.removeAll(where: {$0.id == id})
            }
        }
    }
    
    func toggleSelectedUser(user: TestUser) {
        user.isSelected = !user.isSelected
        if let index = selectedUsers.firstIndex(where: {$0.id == user.id}) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
}
