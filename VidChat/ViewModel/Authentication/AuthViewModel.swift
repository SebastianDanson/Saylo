//
//  AuthViewModel.swift
//  VidChat
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
    @Published var profileImageUrl: String?
    
    static let shared = AuthViewModel()
    
    private init() {
        
        fetchUser()
        
//        COLLECTION_USERS.getDocuments { documents, _ in
//            documents?.documents.forEach({ document in
//                
//                var keywords = self.addKeyWords(name: document.data()["username"] as? String ?? "")
//                keywords.append(contentsOf: self.addKeyWords(name: document.data()["firstName"] as? String ?? ""))
//                keywords.append(contentsOf: self.addKeyWords(name: document.data()["lastName"] as? String ?? ""))
//
//                COLLECTION_USERS.document(document.documentID).updateData(["searchKeywords":keywords, "firstNameKeywords":FieldValue.delete(), "lastNameKeywords":FieldValue.delete(), "usernameKeywords":FieldValue.delete()])
//
//            })
//        }
    }
    
    func login(withEmail email: String, password: String, completion: @escaping((Error?) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
                return
            }
            
            self.isSignedIn = true
            self.fetchUser()
            
            completion(error)
        }
    }
    
    func register(withEmail email: String, password: String, completion: @escaping((Error?) -> Void)) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        
            guard let user = result?.user else {
                completion(error)
                return
            }
            
            let data = ["email":email,
                        "createdAt":Timestamp(date: Date()),
                        "uid": user.uid] as [String : Any]
            
            self.currentUser = User(dictionary: data, id: user.uid)
            
            COLLECTION_USERS.document(user.uid).setData(data) { _ in
                //self.userSession = user
                self.fetchUser()
            }
            
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

        guard var currentUser = currentUser else {
            return
        }

        currentUser.firstName = firstName
        currentUser.lastName = lastName
        
        var keywords = addKeyWords(name: firstName)
        keywords.append(contentsOf: addKeyWords(name: lastName))

        COLLECTION_USERS.document(currentUser.id).updateData(["firstName":firstName, "lastName":lastName,
                                                              "searchKeywords":FieldValue.arrayUnion([keywords])])

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

            guard var currentUser = self.currentUser else {
                return
            }

            currentUser.username = username
            let keywords = self.addKeyWords(name: username)

            COLLECTION_USERS.document(currentUser.id).updateData(["username":username, "searchKeywords":FieldValue.arrayUnion([keywords])])
            
            completion(false)
        }
    }
    
    
    func setProfileImage(image: UIImage) {
        
        guard var currentUser = currentUser else { return }
        hasCompletedSignUp = true
        CameraViewModel.shared.photo = nil
        MediaUploader.uploadImage(image: image, type: .profile) { imageUrl in
            currentUser.profileImageUrl = imageUrl
            self.profileImageUrl = imageUrl
            COLLECTION_USERS.document(currentUser.id).updateData(["profileImageUrl":imageUrl, "hasCompletedSignUp":true])
        }
    }
    
    
    func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            
            if let data = snapshot?.data() {
                
                let user = User(dictionary: data, id: uid)
                self.currentUser = user
                self.profileImageUrl = user.profileImageUrl
                
                /*
                 * Ensure user has completed the full sign up process
                 * If not take them to the landing page view
                 * And redirect them to the auth view that they didn't complete
                 */
                if data["hasCompletedSignUp"] as? Bool ?? false == false {
                    self.hasCompletedSignUp = false
                    LandingPageViewModel.shared.setAuthView()
                }
               
            } else {
                try! Auth.auth().signOut()
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
}

