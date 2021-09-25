//
//  ImageUploader.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import UIKit
import Firebase

enum UploadType {
    case profile, post
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        
        switch self {
        case .post:
            return Storage.storage().reference(withPath: "/profileImages/\(filename)")
        case .profile:
            return Storage.storage().reference(withPath: "/post_images/\(filename)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, type: UploadType, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download image URL \(error.localizedDescription)")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {return}
                completion(imageUrl)
            }
        }
    }
}
