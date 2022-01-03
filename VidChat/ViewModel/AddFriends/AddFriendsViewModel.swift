//
//  AddFriendsViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//


import SwiftUI
import Firebase

class AddFriendsViewModel: ObservableObject {
    
    @Published var scrollViewContentOffset = CGFloat(0)
    @Published var allowGesture = false
    @Published var isSearching: Bool = false
    @Published var searchedUsers = [User]()
    @Published var friendRequests = [User]()

    var showSearchResults = false
    
    static let shared = AddFriendsViewModel()
    
    private init() {}
    
    func search(withText text: String) {
        
        if text.count == 0 {
            searchedUsers = [User]()
            return
        }
        
        searchedUsers = [User]()
        queryResults(searchText: text.lowercased())
    }
    
    
    func queryResults(searchText: String) {
        if searchText.count == 0 {return}
        let searchArray = searchText.components(separatedBy: " ")
        
        getUserSearchResults(searchArray: searchArray, searchText: searchText) { results in
            if self.showSearchResults {
                withAnimation {
                    self.searchedUsers = results
                }
            }
        }
    }
    
    private struct UserSearch {
        let user: User
        let relevancy: Int
    }
    
    func sortResults(searchText: String, searchResults: [User]) -> [User] {
        
        var sortedSearch = [UserSearch]()
        
        var users = [User]()
        
        for i in 0..<searchResults.count {
            
            var relevancy = commonChars(s1: searchResults[i].username, s2: searchText)
            relevancy += commonChars(s1: searchResults[i].firstName, s2: searchText)
            relevancy += commonChars(s1: searchResults[i].lastName, s2: searchText)
            
            //            let dif = abs(self.searchResults[i].getSeachResult().count-searchText.count)
            
            //            let relevancyNum = Double(relevancy)/Double(dif)
            //            self.searchResults[option].setRelevancy(relevancy: relevancyNum)
            
            print(relevancy, searchResults[i].username, searchResults[i].firstName, searchResults[i].lastName, "RELEVANCY")
            
            if relevancy > 0 {
                sortedSearch.append(UserSearch(user: searchResults[i], relevancy: relevancy))
            }
        }
        
        sortedSearch.sort { a, b in
            
            let aRelevancy = a.relevancy
            let bRelevancy = b.relevancy
            
            if aRelevancy == bRelevancy {
                return a.user.username.levenshtein(searchText) < b.user.username.levenshtein(searchText)
            } else {
                return bRelevancy > aRelevancy
            }
        }
        
        sortedSearch.forEach({users.append($0.user)})
        
        return users
        
    }
    
    //TODO show "added", instead of "add" once friend request has been sent
    
    
    func getUserSearchResults(searchArray: [String], searchText: String, completion: @escaping([User]) -> Void) {
         
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        
        var searchResults = [User]()
        
        COLLECTION_USERS
            .whereField("searchKeywords", arrayContainsAny: searchArray)
            .limit(to: 10)
            .getDocuments { snapshots, error in
                snapshots?.documents.forEach({ snapshot in
                    let user = User(dictionary: snapshot.data(), id: snapshot.documentID)
                    
                    //Don't show current user in search results
                    if currentUser.id != user.id {
                        searchResults.append(user)

                    }
                })
                completion(self.sortResults(searchText: searchText, searchResults: searchResults))
            }
    }
    
    
    func commonChars(s1: String, s2: String) -> Int {
        return s1.lowercased().levenshtein(s2.lowercased())
    }
    
    func sendFriendRequest(toUser user: User) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        COLLECTION_USERS.document(user.id).updateData(["friendRequests": FieldValue.arrayUnion([currentUser.id]),
                                                       "hasUnseenFriendRequest":true])
    }
    
    func removeFriendRequest(toUser user: User) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        COLLECTION_USERS.document(user.id).updateData(["friendRequests": FieldValue.arrayRemove([currentUser.id])])
    }
    
    func rejectFriendRequest(fromUser user: User) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        currentUser.friendRequests.removeAll(where: {$0 == user.id})
        COLLECTION_USERS.document(currentUser.id).updateData(["friendRequests": FieldValue.arrayRemove([user.id])])
    }
    
    func acceptFriendRequest(fromUser friend: User) {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        let chatId: String!
        
        if user.id > friend.id {
            chatId = user.id + friend.id
        } else {
            chatId = friend.id + user.id
        }
        
        let userData = [
            "userId": user.id,
            "profileImage": user.profileImageUrl,
            "fcmToken":user.fcmToken,
            "pushKitToken":user.pushKitToken,
            "username":user.username,
            "firstName":user.firstName,
            "lastName":user.lastName
        ]
        
        let friendData = [
            "userId": friend.id,
            "profileImage": friend.profileImageUrl,
            "fcmToken":friend.fcmToken,
            "pushKitToken":friend.pushKitToken,
            "username":friend.username,
            "firstName":friend.firstName,
            "lastName":friend.lastName
        ]
        
        COLLECTION_CONVERSATIONS.document(chatId).setData(["users":[userData,friendData], "isDm":true])
        
        let chatData = ["id":chatId,
                        "lastVisited": Int(Date().timeIntervalSince1970 * 1000),
                        "notificationsEnabled": true] as [String: Any]
        
        ConversationGridViewModel.shared.addConversation(withId: chatId)
        
        COLLECTION_USERS.document(user.id)
            .updateData(
                ["friendRequests" : FieldValue.arrayRemove([friend.id]),
                 "friends": FieldValue.arrayUnion([friend.id]),
                 "conversations": FieldValue.arrayUnion([chatData])])
        
        user.friends.append(friend.id)
        user.chats.append(UserChat(dictionary: chatData))
        user.friendRequests.removeAll(where: {$0 == friend.id})
        
        COLLECTION_USERS.document(friend.id)
            .updateData(
                ["friends": FieldValue.arrayUnion([user.id]),
                 "conversations": FieldValue.arrayUnion([chatData])])
    }
    
    func fetchFriendRequests() {
        AuthViewModel.shared.fetchUser {
            guard let currentUser = AuthViewModel.shared.currentUser else {return}
            
            currentUser.friendRequests.forEach { uid in
                
                COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
                    if let data = snapshot?.data() {
                        let user = User(dictionary: data, id: uid)
                        
                        if !self.friendRequests.contains(where: {$0.id == user.id}) && !currentUser.friends.contains(user.id){
                            self.friendRequests.append(user)
                        }
                    }
                }
            }
        }
    }
    
    func setSeenFriendRequests() {
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        currentUser.hasUnseenFriendRequest = false
        COLLECTION_USERS.document(currentUser.id).updateData(["hasUnseenFriendRequest":false])
    }
    
    func reset() {
        searchedUsers = [User]()
        friendRequests = [User]()
        isSearching = false
        showSearchResults = false
    }
}
