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
    @Published var selectedUsers = [User]()
    @Published var showSearchBar: Bool = false
    @Published var showSettingsView: Bool = false
    @Published var showAddFriends: Bool = false
    @Published var showNewChat: Bool = false
    @Published var users: [User]
    
    let allUsers: [User]
    
    
    static let shared = ConversationGridViewModel()
    
    private init() {
        
        let image1 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%202.54.09%20PM.png?alt=media&token=0a1b499c-a2d9-416f-ab99-3f965939ed66"
        let image2 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%203.23.09%20PM.png?alt=media&token=e1ff51b5-3534-439b-9334-d2f5bc1e37c1"
        let image3 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Slice%20102.png?alt=media&token=8f470a6e-738b-4724-8fe9-ada2305d48ef"
        
        let users = [User]()
          
        
        self.allUsers = users
        
        self.users = users
    }
    
    func removeSelectedUser(withId id: String) {
        if let index = selectedUsers.firstIndex(where: {$0.id == id}) {
            withAnimation {
                //TODO handle isSelected
//                selectedUsers[index].isSelected = !selectedUsers[index].isSelected
                selectedUsers.removeAll(where: {$0.id == id})
            }
        }
    }
    
    func toggleSelectedUser(user: User) {
        //TODO handle isSelected
//        user.isSelected = !user.isSelected
        if let index = selectedUsers.firstIndex(where: {$0.id == user.id}) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
    
    func showAllUsers() {
        self.users = self.allUsers
    }
    
    func filterUsers(withText text: String) {
        withAnimation {
            self.users = self.allUsers.filter({ $0.firstName.starts(with: text) ||  $0.lastName.starts(with: text) })
        }
    }
}
