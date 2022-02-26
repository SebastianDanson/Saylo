//
//  Post.swift
//  Saylo
//
//  Created by Student on 2021-09-24.
//

import FirebaseFirestore
import Firebase
import UIKit
import AVFoundation

enum MainViewType {
    case Saylo, Voice, Video, Photo, Note
}

enum MessageType {
    
    case Video, Audio, Text, Photo, NewChat
    
    static func getType(forString type: String) -> MessageType {
        switch type {
        case "video":
            return .Video
        case "audio":
            return .Audio
        case "text":
            return .Text
        case "photo":
            return .Photo
        case "newChat":
            return .NewChat
        default:
            print("DEBUG: ERROR Can't identify message type")
            return .Video
        }
    }
    
    func getString() -> String {
        switch self {
        case .Photo:
            return "photo"
        case .Text:
            return "text"
        case .Audio:
            return "audio"
        case .Video:
            return "video"
        case .NewChat:
            return "newChat"
        }
    }
}

class Message: ObservableObject {
    
    //ids
    let id: String
    let chatId: String
    
    //userInfo
    let username: String
    let userId: String
    let userProfileImage: String
    
    //Content
    let type: MessageType
    var url: String?
    var asset: AVURLAsset?
    let text: String?
    var image: UIImage?
    var isFromPhotoLibrary: Bool
    var reactions = [Reaction]()
    var isTeamSayloMessage: Bool

    //data
    @Published var isSaved: Bool
    @Published var isSameIdAsPrevMessage = false
    @Published var isSameIdAsNextMessage = false
    
    var isFromCurrentUser: Bool
    var savedByCurrentUser: Bool
    
    //Bool for conversation player view that indicates to show the cameraview instead of a message
    var isForTakingVideo: Bool
    
    
    //date
    let timestamp: Timestamp
    
    init(dictionary: [String:Any], id: String, exportVideo: Bool = true, isSaved: Bool = false, savedByUid: String = "", isForTakingVideo: Bool = false) {
        
        //ids
        self.id = id
        self.chatId = dictionary["chatId"] as? String ?? ""
        
        //userInfo
        self.userId = dictionary["userId"] as? String ?? ""
                      
        
        if userId == AuthViewModel.shared.currentUser?.id ?? UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)?.string(forKey: "userId") {
            self.username = "Me"
            self.isFromCurrentUser = true
        } else {
            self.username = dictionary["username"] as? String ?? ""
            self.isFromCurrentUser = false
        }
        
        self.userProfileImage = dictionary["userProfileImage"] as? String ?? ""
        
        //content
        self.url = dictionary["url"] as? String
        self.type = MessageType.getType(forString: dictionary["type"] as? String ?? "")
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: TimeInterval(dictionary["timestamp"] as? Int ?? 0)))
        self.text = dictionary["text"] as? String
        
        self.isTeamSayloMessage = dictionary["isTeamSayloMessage"] as? Bool ?? false

        self.isFromPhotoLibrary = dictionary["isFromPhotoLibrary"] as? Bool ?? true
        
        self.isSaved = isSaved
        self.savedByCurrentUser = savedByUid == Auth.auth().currentUser?.uid
        
        self.isForTakingVideo = isForTakingVideo
        
        //checkCache
        if type == .Video || type == .Audio, exportVideo, let urlString = url, let url = URL(string: urlString) {
            let storedUrl = dictionary["userStoredUrl"] as? String ?? ""
            self.url = CacheManager.getCachedUrl(url, userStoredURL: URL(string: storedUrl), isVideo: type == .Video).absoluteString
        }
    }
    
    func getDictionary() -> [String:Any] {
                
        var dictionary = [
            "id":id,
            "userProfileImage":userProfileImage,
            "username": username,
            "timestamp": Int(timestamp.dateValue().timeIntervalSince1970)
        ] as [String: Any]
        
        if let url = url {
            dictionary["url"] = url
            
            if type == .Video {
                dictionary["userStoredUrl"] = url
                dictionary["type"] = "video"
            } else {
                dictionary["type"] = "audio"
            }
        }
        
        if type == .Photo {
            dictionary["type"] = "photo"
            
            if !isFromPhotoLibrary {
                dictionary["isFromPhotoLibrary"] = false
            }
        }
        
        if let text = text {
            dictionary["text"] = text
            dictionary["type"] = "text"
        }
       
        return dictionary
    }
}


