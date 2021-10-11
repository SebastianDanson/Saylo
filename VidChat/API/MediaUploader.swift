//
//  ImageUploader.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import UIKit
import Firebase

enum UploadType {
    case profile, video
    
    var filePath: StorageReference {
        let filename = NSUUID().uuidString
        
        switch self {
        case .video:
            return Storage.storage().reference(withPath: "/videos/\(filename)")
        case .profile:
            return Storage.storage().reference(withPath: "/profileImages/\(filename)")
        }
    }
}

struct MediaUploader {
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
    
    static func uploadVideo(url: URL, completion: @escaping(String) -> Void) {
        
        let ref = UploadType.video.filePath
        ref.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload video \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download video URL \(error.localizedDescription)")
                    return
                }
                
                guard let videoUrl = url?.absoluteString else {return}
                completion(videoUrl)
            }
        }
    }
}
