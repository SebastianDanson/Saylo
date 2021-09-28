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
    
    static let shared = AuthViewModel()
    
    init() {
        fetchUser()
    }
    
    func login(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Login failed \(error.localizedDescription)")
                return
            }
            
            self.fetchUser()
        }
    }
    
    func register(withEmail email: String, password: String, image: UIImage?, fullName: String, userName: String) {
       // guard let image = image else {return}
       // ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else {return}
                
                let data = ["email":email,
                            "username":userName,
                            "fullName":fullName,
                            "createdAt":Timestamp(date: Date()),
                           // "profileImageUrl":imageUrl,
                            "uid": user.uid] as [String : Any]
                
                COLLECTION_USERS.document(user.uid).setData(data) { _ in
                    //self.userSession = user
                    self.fetchUser()
                }
            }
        //}
    }
    
    func signOut() {
        self.currentUser = nil
        try? Auth.auth().signOut()
    }

    func resetPassword(withEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Failed to send link with error \(error.localizedDescription)")
                return
            }
            
            self.didSendResetPasswordLink = true
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let user = User(dictionary: data, id: uid)
                self.currentUser = user
            }
        }
    }
    
}
