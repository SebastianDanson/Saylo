//
//  AddFriendsViewModel.swift
//  Saylo
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
    @Published var contacts: [PhoneContact]?
    @Published var contactsOnSaylo = [User]()
    
    var allContacts = [PhoneContact]()
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
    
    func setContacts(count: Int? = nil) {
        guard var contacts =  ContactsViewModel.shared.getPhoneContacts() else {return}
        contacts.removeAll(where: {$0.name == nil || $0.name?.replacingOccurrences(of: " ", with: "") == ""})
        
        
        if let count = count, contacts.count >= count {
            contacts = contacts.shuffled()
            self.contacts = [PhoneContact]()
            for i in 0..<count {
                self.contacts!.append(contacts[i])
            }
        } else {
            self.contacts = contacts
                .sorted(by: { ($0.name?.replacingOccurrences(of: " ", with: "").lowercased() ?? "") < ($1.name?.replacingOccurrences(of: " ", with: "").lowercased() ?? "")})
        }
        
        self.allContacts = contacts
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
            
            var relevancy = commonChars(s1: searchResults[i].username, s2: searchText) * 2
            relevancy += commonChars(s1: searchResults[i].firstName, s2: searchText)
            relevancy += commonChars(s1: searchResults[i].lastName, s2: searchText)
            
            let searchResultCount = (searchResults[i].username.count + searchResults[i].firstName.count + searchResults[i].lastName.count)/2
            
            let dif = abs(searchResultCount-searchText.count)
            let relevancyNum = Double(relevancy)/Double(dif)
            
            
            if relevancyNum > 2.5 {
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
    
    func sendFriendRequest(toUser user: ChatMember) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        
        let chatId: String!
        
        if currentUser.id > user.id {
            chatId = currentUser.id + user.id
        } else {
            chatId = user.id + currentUser.id
        }
        
        let userData = [
            "userId": user.id,
            "profileImage": user.profileImage,
            "pushKitToken":user.pushKitToken,
            "username":user.username,
            "firstName":user.firstName,
            "lastName":user.lastName
        ]
        
        COLLECTION_CONVERSATIONS.document(chatId).setData(["users":[userData], "messages" : [], "isDm":true])
        
        COLLECTION_SAVED_POSTS.document(chatId).getDocument { snapshot, _ in
            if let snapshot = snapshot, !snapshot.exists {
                COLLECTION_SAVED_POSTS.document(chatId).setData(["messages":[]])
            }
        }
        
        let chatData = ["id":chatId,
                        "lastVisited": Timestamp(date: Date()),
                        "notificationsEnabled": true] as [String: Any]
        
        ConversationGridViewModel.shared.addConversation(withId: chatId) { }
        
        COLLECTION_USERS.document(currentUser.id)
            .updateData(
                ["conversations": FieldValue.arrayUnion([chatData])]) { error in
                    ConversationGridViewModel.shared.fetchConversations()
                }
        
        currentUser.chats.append(UserChat(dictionary: chatData))
        currentUser.conversationsDic.append(chatData)

        
        let userRef = COLLECTION_USERS.document(user.id)
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["friendRequests": FieldValue.arrayUnion([currentUser.id]),
                                    "hasUnseenFriendRequest":true], forDocument: userRef)
            return nil
        }) { (_, error) in }
        
        
        var data = [String:Any]()
        
        data["token"] = user.fcmToken
        data["title"] = currentUser.firstName + " " + currentUser.lastName
        data["body"] = "Sent you a friend request"
        data["metaData"] = ["isSentFriendRequest":true]
        
        Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
    }
    
    func removeFriendRequest(toUser user: ChatMember) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        var chats = currentUser.chats
        
        let chatId: String!
        
        if currentUser.id > user.id {
            chatId = currentUser.id + user.id
        } else {
            chatId = user.id + currentUser.id
        }

        chats.removeAll(where: { $0.id == chatId })
        
        var conversationsDic = [[String:Any]]()
        
        chats.forEach { chat in
            conversationsDic.append(chat.getDictionary())
        }
        
        
        
        
        let userRef = COLLECTION_USERS.document(currentUser.id)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["conversations":conversationsDic], forDocument: userRef)
            return nil
        }) { (_, error) in
            AuthViewModel.shared.fetchUser {
                ConversationGridViewModel.shared.fetchConversations()
            }
        }
        
        
        COLLECTION_USERS.document(user.id).updateData(["friendRequests": FieldValue.arrayRemove([currentUser.id])])
        
        
        
    }
    
    func rejectFriendRequest(fromUser user: ChatMember) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        currentUser.friendRequests.removeAll(where: {$0 == user.id})
        
        COLLECTION_USERS.document(currentUser.id).updateData(["friendRequests": FieldValue.arrayRemove([user.id])])
        
        let chatId: String!
        
        if currentUser.id > user.id {
            chatId = currentUser.id + user.id
        } else {
            chatId = user.id + currentUser.id
        }
        
        COLLECTION_USERS.document(user.id).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
                
                var conversations = data["conversations"] as? [[String:Any]] ?? [[String:Any]]()
                
                conversations.removeAll(where: {$0["id"] as? String == chatId})
                
                let userRef = COLLECTION_USERS.document(user.id)
                Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                    transaction.updateData(["conversations": conversations], forDocument: userRef)
                    return nil
                }) { (_, error) in }
            }
        }
    }
    
    func acceptFriendRequest(fromUser friend: ChatMember) {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        let chatId: String!
        
        if user.id > friend.id {
            chatId = user.id + friend.id
        } else {
            chatId = friend.id + user.id
        }
        
        guard !user.chats.contains(where: {$0.id == chatId}) else { return }

        
        let userData = [
            "userId": user.id,
            "profileImage": user.profileImage,
            "fcmToken":user.fcmToken,
            "pushKitToken":user.pushKitToken,
            "username":user.username,
            "firstName":user.firstName,
            "lastName":user.lastName
        ]
        
        let friendData = [
            "userId": friend.id,
            "profileImage": friend.profileImage,
            "fcmToken":friend.fcmToken,
            "pushKitToken":friend.pushKitToken,
            "username":friend.username,
            "firstName":friend.firstName,
            "lastName":friend.lastName
        ]
        
        
        let chatRef = COLLECTION_CONVERSATIONS.document(chatId)
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            transaction.updateData(["users":[userData,friendData]], forDocument: chatRef)
            return nil
        }) { (_, error) in
            ConversationGridViewModel.shared.fetchConversations(updateFriendsView: true)
        }
        
        
        
        let chatData = ["id":chatId,
                        "lastVisited": Timestamp(date: Date()),
                        "notificationsEnabled": true] as [String: Any]
        
//        ConversationGridViewModel.shared.addConversation(withId: chatId) { }
        
        COLLECTION_USERS.document(user.id)
            .updateData(
                ["friendRequests" : FieldValue.arrayRemove([friend.id]),
                 "friends": FieldValue.arrayUnion([friend.id]),
                 "conversations": FieldValue.arrayUnion([chatData])]) { error in
                     ConversationGridViewModel.shared.fetchConversations()
                 }
        
        user.friends.append(friend.id)
        user.chats.append(UserChat(dictionary: chatData))
        user.conversationsDic.append(chatData)
        user.friendRequests.removeAll(where: {$0 == friend.id})
        
        COLLECTION_USERS.document(friend.id)
            .updateData(
                ["friends": FieldValue.arrayUnion([user.id])]) { error in
                    
                    if error == nil {
                        var data = [String:Any]()
                        
                        data["token"] = friend.fcmToken
                        data["title"] = user.firstName + " " + user.lastName
                        data["body"] = "Accepted your friend request"
                        data["metaData"] = ["acceptedFriendRequest":true]
                        
                        Functions.functions().httpsCallable("sendNotification").call(data) { (result, error) in }
                    }
                }
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
        let currentUserId = AuthViewModel.shared.getUserId()
        
        AuthViewModel.shared.hasUnseenFriendRequest = false
        
        if currentUserId != "" {
            COLLECTION_USERS.document(currentUserId).updateData(["hasUnseenFriendRequest":false])
        }
    }
    
    func reset() {
        searchedUsers = [User]()
        friendRequests = [User]()
        isSearching = false
        showSearchResults = false
    }
    
    
    func filterUsers(withText text: String) {
        
        withAnimation {
            
            self.contacts = self.allContacts.filter({
                
                let wordArray = $0.name?.components(separatedBy: [" "])
                var contains = false
                
                wordArray?.forEach({
                    if $0.starts(with: text) {
                        contains = true
                    }
                })
                
                return contains
            })
            
        }
    }
}
