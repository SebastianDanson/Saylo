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
        
    static let shared = AuthViewModel()
    
    private init() {
        fetchUser()
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
            
            self.isSignedIn = true
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

        print(firstName)
        print(lastName)
        guard var currentUser = currentUser else {
            return
        }

        currentUser.fullname = firstName + " " + lastName
        
        COLLECTION_USERS.document(currentUser.id).updateData(["firstName":firstName, "lastName":lastName])

    }
    
    
    func setUsername(username: String, completion: @escaping(Bool) -> Void) {
                
        var username = username
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

            COLLECTION_USERS.document(currentUser.id).updateData(["username":username])
            
            completion(false)
        }
    }
    
    
    func setProfileImage(image: UIImage) {
        
        guard var currentUser = currentUser else { return }
        
        MediaUploader.uploadImage(image: image, type: .profile) { imageUrl in
            currentUser.profileImageUrl = imageUrl
            COLLECTION_USERS.document(currentUser.id).updateData(["profileImageUrl":imageUrl])
        }
    }
    
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let user = User(dictionary: data, id: uid)
                self.currentUser = user
            } else {
                try! Auth.auth().signOut()
                
            }
        }
    }
    
}

