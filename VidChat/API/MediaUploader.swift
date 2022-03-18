//
//  ImageUploader.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//

import UIKit
import Firebase
import AVFoundation
import AssetsLibrary
import Foundation
import QuartzCore
import SwiftUI

enum UploadType {
    case profile, video, photo, audio, chat
    
    
    func getFilePath(messageId: String) -> StorageReference {
        
        switch self {
        case .audio:
            return Storage.storage().reference(withPath: "/audioRecordings/\(messageId)")
        case .video:
            return Storage.storage().reference(withPath: "/videos/\(messageId)")
        case .photo:
            return Storage.storage().reference(withPath: "/photos/\(messageId)")
        case .profile:
            return Storage.storage().reference(withPath: "/profileImages/\(messageId)")
        case .chat:
            return Storage.storage().reference(withPath: "/chatProfileImages/\(messageId)")
        }
    }
}

class MediaUploader {
    
    static let shared = MediaUploader()
    static var uploadTask: StorageUploadTask?
    
    func checkFileSize(sizeUrl: URL, message:String){
        let data = NSData(contentsOf: sizeUrl)!
    }
    
    static func uploadImage(image: UIImage, type: UploadType, messageId: String, completion: @escaping(String) -> Void) {
        
        var width = image.size.width
        var height = image.size.height
        
        let targetDimension: CGFloat = type == .profile ? 300 : 700
        
        if height > targetDimension || width > targetDimension {
            if width > height {
                let const = targetDimension/width
                width *= const
                height *= const
            } else {
                let const = targetDimension/height
                width *= const
                height *= const
            }
        }
        
        guard let imageData = shared.resizedImageWith(image: image, targetSize: CGSize(width: width, height: height))?.jpegData(compressionQuality: 0.5) else {return}
        
        let ref = type.getFilePath(messageId: messageId)
        
        let uploadTask = ref.putData(imageData, metadata: nil) { _, error in
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
        
    
        uploadTask.observe(.progress) { snapshot in
            
            if let progress = snapshot.progress {
            
                withAnimation {
                    ConversationViewModel.shared.uploadProgress = progress.fractionCompleted
                }
            }
        }
        
        MediaUploader.uploadTask = uploadTask

    }
    
    func uploadAudio(url: URL, messageId: String, completion: @escaping(String) -> Void) {
        
        let ref = UploadType.audio.getFilePath(messageId: messageId)

        let uploadTask = ref.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload audio \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download audio URL \(error.localizedDescription)")
                    return
                }
                
                guard let audioUrl = url?.absoluteString else {return}
                completion(audioUrl)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            
            if let progress = snapshot.progress {
            
                withAnimation {
                    ConversationViewModel.shared.uploadProgress = progress.fractionCompleted
                }
            }
        }
        
        MediaUploader.uploadTask = uploadTask

    }
    
    func uploadVideo(url: URL, messageId: String, isFromPhotoLibrary: Bool, completion: @escaping(String) -> Void) {
        
        let ref = UploadType.video.getFilePath(messageId: messageId)

        if isFromPhotoLibrary {
            let videoData = try! Data(contentsOf: url)
            
            let metadata = StorageMetadata()
            metadata.contentType = "video/quicktime"
            
            let uploadTask = ref.putData(videoData, metadata: metadata) { _, error in
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
            
            uploadTask.observe(.progress) { snapshot in
                
                if let progress = snapshot.progress {
                
                    withAnimation {
                        ConversationViewModel.shared.uploadProgress = progress.fractionCompleted
                    }
                }
            }
            
            MediaUploader.uploadTask = uploadTask

        } else {
            
            
           let uploadTask = ref.putFile(from: url, metadata: nil) { _, error in
                
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
            
            
            uploadTask.observe(.progress) { snapshot in
                
                if let progress = snapshot.progress {
                
                    withAnimation {
                        ConversationViewModel.shared.uploadProgress = progress.fractionCompleted
                    }
                }
            }

            MediaUploader.uploadTask = uploadTask
            
        }
    }
    
    func resizedImageWith(image: UIImage, targetSize: CGSize) -> UIImage? {
        
        let imageSize = image.size
        let newWidth  = targetSize.width  / image.size.width
        let newHeight = targetSize.height / image.size.height
        var newSize: CGSize
        
        if(newWidth > newHeight) {
            newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
        } else {
            newSize = CGSize(width: imageSize.width * newWidth,  height: imageSize.height * newWidth)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// Angle Conversion Utility
extension Int {
    var degreesToRadiansCGFloat: CGFloat { return CGFloat(Double(self) * Double.pi / 180) }
}

