//
//  Post.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import FirebaseFirestore
import Firebase
import UIKit
import AVFoundation

enum MessageType {
    case Video, Audio, Text, Photo
    
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
        default:
            print("DEBUG: ERROR Can't identify message type")
            return .Video
        }
    }
}

class Message: Identifiable {
    
    //ids
    let id: String
    let chatId: String
    
    //userInfo
    let username: String
    let userId: String
    let userProfileImageUrl: String
    
    //Content
    let type: MessageType
    var url: String?
    var asset: AVURLAsset?
    let text: String?
    var image: UIImage?
    
    //date
    let timestamp: Timestamp
    
    init(dictionary: [String:Any], id: String) {
        
        //ids
        self.id = id
        self.chatId = dictionary["chatId"] as? String ?? ""
        
        //userInfo
        self.userId = dictionary["userId"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        
        //content
        self.url = dictionary["url"] as? String
        self.type = MessageType.getType(forString: dictionary["type"] as? String ?? "")
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        self.text = dictionary["text"] as? String
        
        //checkCache
        if let urlString = url, let url = URL(string: urlString) {
            self.url = CacheManager.getCachedUrl(url, isVideo: type == .Video).absoluteString
        }
    }
}


