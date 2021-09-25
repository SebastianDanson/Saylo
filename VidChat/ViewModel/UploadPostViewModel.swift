//
//  UploadPostViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Firebase

class UploadPostViewModel: ObservableObject {
     
    func uploadPost(caption: String, image: UIImage, completion: FireStoreCompletion) {
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        ImageUploader.uploadImage(image: image, type: .post) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerImageUrl":user.profileImageUrl,
                        "ownerUid": user.id,
                        "ownerUsername": user.username] as [String : Any]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
}
