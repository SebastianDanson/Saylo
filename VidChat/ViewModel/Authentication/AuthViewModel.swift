//
//  AuthViewModel.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var didSendResetPasswordLink = false
    @Published var isSignedIn = Auth.auth().currentUser != nil
    @Published var hasCompletedSignUp = true
    @Published var profileImage: String?
    @Published var hasUnseenFriendRequest: Bool = false
    
    static let shared = AuthViewModel()
    
    private init() {
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        self.profileImage = defaults?.string(forKey: "profileImage")
    }
    
    func getUserId() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    func login(withEmail email: String, password: String, completion: @escaping((Error?) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            guard let user = result?.user else {
                completion(error)
                return
            }
            
            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
            defaults?.set(user.uid, forKey: "userId")
            
            self.isSignedIn = true
            self.fetchUser {
                ConversationGridViewModel.shared.fetchConversations()
            }
            
            completion(error)
        }
    }
    
    func register(withEmail email: String, password: String, completion: @escaping((Error?) -> Void)) {
        
       
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            guard let user = result?.user else {
                completion(error)
                return
            }

            let chatRef = COLLECTION_CONVERSATIONS.document()
            let chatId = chatRef.documentID
            
            let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 100)
            
            
            //Add Team Saylo chat
            
            let chatData = ["id": chatId,
                            "lastVisited": Timestamp(date: date),
                            "notificationsEnabled": true] as [String: Any]
            
            let messageData = ["chatId":chatId,
                               "id":UUID().uuidString,
                               "type":"video",
                               "isTeamSayloMessage": true,
                               "url":"https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/App%20Preview%20Final.mov?alt=media&token=cb0fc5c9-a2a6-4c52-adbc-ff41fa52fb7a"] as [String : Any]
            
            COLLECTION_CONVERSATIONS.document(chatId).setData([
                "isTeamSaylo":true,
                "messages" : [messageData],
                "name":"Saylo",
                "profileImage": "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/SayloChatProfileImage.png?alt=media&token=7f950121-b7e6-444d-9025-2e4501958735"])
            
            
            let data = ["email":email,
                        "createdAt":Timestamp(date: Date()),
                        "uid": user.uid,
                        "conversations":[chatData]] as [String : Any]
            
            self.currentUser = User(dictionary: data, id: user.uid)
            
            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
            defaults?.set(user.uid, forKey: "userId")
            defaults?.set(chatId, forKey: "teamSayloId")

            COLLECTION_USERS.document(user.uid).setData(data) { _ in }
            
            completion(error)
        }
    }
    
    func signOut() {
        self.currentUser = nil
        try? Auth.auth().signOut()
    }
    
    func resetPassword(withEmail email: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    func setName(firstName: String, lastName: String) {
        
        var firstName = firstName
        var lastName = lastName
        
        firstName.removeTrailingSpaces()
        lastName.removeTrailingSpaces()
        
        guard let currentUser = currentUser else {
            return
        }
        
        currentUser.firstName = firstName
        currentUser.lastName = lastName
        
        var keywords = addKeyWords(name: firstName)
        keywords.append(contentsOf: addKeyWords(name: lastName))
        
        COLLECTION_USERS.document(currentUser.id).updateData(["firstName":firstName, "lastName":lastName,
                                                              "searchKeywords":FieldValue.arrayUnion(keywords)])
        
    }
    
    
    func setUsername(username: String, completion: @escaping(Bool) -> Void) {
        
        var username = username.lowercased()
        username.removeTrailingSpaces()
        
        COLLECTION_USERS.whereField("username", isEqualTo: username).getDocuments { snapshot, _ in
            
            if snapshot?.documents.count ?? 0 > 0 {
                
                //username alreay taken
                completion(true)
                return
            }
            
            //username is available
            
            guard let currentUser = self.currentUser else {
                return
            }
            
            currentUser.username = username
            let keywords = self.addKeyWords(name: username)
            
            COLLECTION_USERS.document(currentUser.id).updateData(["username":username, "searchKeywords":FieldValue.arrayUnion(keywords)])
            
            completion(false)
        }
    }
    
    func setPhoneNumber(phoneNumber: String, countryCode: String, completion: @escaping((Error?) -> Void)) {
        
        guard let id = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(id).updateData(["phoneNumber":phoneNumber, "countryCode":countryCode])
        
        sendPhoneVerificationCode(phoneNumber: phoneNumber, countryCode: countryCode) { error in
            completion(error)
        }
    }
    
    func sendPhoneVerificationCode(phoneNumber: String, countryCode: String, completion: @escaping((Error?) -> Void)) {
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber("+" + countryCode + phoneNumber, uiDelegate: nil) { verificationID, error in
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(error)
            }
    }
    
    func verifyPhone(verificationCode: String, completion: @escaping((Error?) -> Void)) {
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().currentUser?.link(with: credential, completion: { authResult, error in
            completion(error)
        })

    }
    
    
    func setProfileImage(image: UIImage, completion: @escaping(() -> Void)) {
        
        guard let currentUser = currentUser else { return }
        CameraViewModel.shared.photo = nil
        MediaUploader.uploadImage(image: image, type: .profile, messageId: UUID().uuidString) { imageUrl in
            
            AuthViewModel.shared.currentUser?.profileImage = imageUrl
            
            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
            defaults?.set(imageUrl, forKey: "profileImage")
            
            self.profileImage = imageUrl
            COLLECTION_USERS.document(currentUser.id).updateData(["profileImage":imageUrl, "hasCompletedSignUp":true]) { error in
                completion()
            }
        }
    }
    
    
    func fetchUser(completion: @escaping(() -> Void)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
                
                let user = User(dictionary: data, id: uid)
                self.currentUser = user
                self.profileImage = user.profileImage
                
                let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
                defaults?.set(user.profileImage, forKey: "profileImage")
                
                /*
                 * Ensure user has completed the full sign up process
                 * If not take them to the landing page view
                 * And redirect them to the auth view that they didn't complete
                 */
                if data["hasCompletedSignUp"] as? Bool ?? false == false {
                    self.hasCompletedSignUp = false
                    LandingPageViewModel.shared.setAuthView()
                }
                
                let fcmToken = UserDefaults.standard.string(forKey: "fcmToken")

                if let fcmToken = fcmToken, !fcmToken.isEmpty {
                    
                    if user.fcmToken != fcmToken {
                        
                        let userRef = COLLECTION_USERS.document(uid)
                        
                        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                            transaction.updateData(["fcmToken" : fcmToken], forDocument: userRef)
                            return nil
                        }) { (_, error) in }
                        
                        self.currentUser?.fcmToken = fcmToken
                        self.updateChatsFcmToken()
                        
                    }
                }
                
                completion()
            } else {
                try! Auth.auth().signOut()
                completion()
            }
        }
    }
    
    func updateChatsFcmToken() {
        
        guard let currentUser = currentUser else {
            return
        }
        
        currentUser.chats.forEach { chat in
            
            COLLECTION_CONVERSATIONS.document(chat.id).getDocument { snapshot, _ in
                
                if let data = snapshot?.data() {
                    
                    var usersDic = data["users"] as? [[String:Any]] ?? [[String:Any]]()
                    
                    for i in 0..<usersDic.count {
                        
                        if usersDic[i]["userId"] as? String == currentUser.id {
                            usersDic[i]["fcmToken"] = currentUser.fcmToken
                        }
                    }
                    
                    let chatRef = COLLECTION_CONVERSATIONS.document(chat.id)
                    
                    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                        transaction.updateData(["users" : usersDic], forDocument: chatRef)
                        return nil
                    }) { (_, error) in }
                }
            }
        }
    }
    
    func logout() {
        
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isSignedIn = false
        } catch {
            
        }
    }
    
    
    func addKeyWords(name: String) -> [String] {
        var letters = [String]()
        var some_letters = [String]()
        let groupName = name.components(separatedBy: [" "])
        
        for word in groupName {
            for j in 1..<word.count + 1 {
                some_letters.append(word.prefix(j).lowercased())
            }
            
            for k in 0..<name.count + 1 {
                letters.append(name.prefix(k).lowercased())
            }
        }
        
        letters = some_letters + letters
        letters = removeDuplicates(strings: letters)
        letters.removeAll(where: {$0 == ""})
        return letters
    }
    
    func removeDuplicates(strings: [String]) -> [String] {
        var result = [String]()
        
        for value in strings {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
    
    
    func updateTeamSayloChat(fcmToken: String) {
        
        let defaults = UserDefaults.standard
        
        guard let teamSayloId = defaults.string(forKey: "teamSayloId") else { return }
        guard let userId = defaults.string(forKey: "userId") else { return }
        
        COLLECTION_USERS.document(userId).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
            
                let user = User(dictionary: data, id: userId)
                
                let userData = [
                    "userId": userId,
                    "profileImage": user.profileImage,
                    "fcmToken":fcmToken,
                    "pushKitToken":user.pushKitToken,
                    "username":user.username,
                    "firstName":user.firstName,
                    "lastName":user.lastName
                ]
                
                COLLECTION_CONVERSATIONS.document(teamSayloId).updateData(["users":FieldValue.arrayUnion([userData])])
            }
        }
      
    }
}

