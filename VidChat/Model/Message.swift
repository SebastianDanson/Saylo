//
//  Post.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import FirebaseFirestore
import Firebase

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

struct Message: Identifiable {
    
    //ids
    let id: String
    let chatId: String
    
    //userInfo
    let username: String
    let userId: String
    let userProfileImageUrl: String

    //Content
    let type: MessageType
    let videoUrl: String?
    
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
        self.videoUrl = dictionary["videoUrl"] as? String
        self.type = MessageType.getType(forString: dictionary["type"] as? String ?? "")
        
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        print( "YUUUH",self.videoUrl, self.type)
    }
}
