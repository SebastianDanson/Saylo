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
    var isFromPhotoLibrary: Bool
    var reactions = [Reaction]()

    //data
    var isSaved: Bool
    var isSameIdAsPrevMessage = false
    
    //date
    let timestamp: Timestamp
    
    init(dictionary: [String:Any], id: String, exportVideo: Bool = true, isSaved: Bool = false) {
        
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
        
        self.isFromPhotoLibrary = dictionary["isFromPhotoLibrary"] as? Bool ?? true
        
        self.isSaved = isSaved
        
        let reactionsDic = dictionary["reactions"] as? [[String:Any]] ?? [[String:Any]]()
        
        reactionsDic.forEach({
            let reactionType = ReactionType.getReactionType(fromString: $0["reactionType"] as? String ?? "")
            let reaction = Reaction(username: $0["username"] as? String ?? "", userId: $0["userId"] as? String ?? "", reactionType: reactionType)
            self.reactions.append(reaction)
            
          

        })
        
        let love = Reaction(username: "Seb", userId: "jhbjh", reactionType: .Love)
        let like = Reaction(username: "Seb", userId: "jhbjh", reactionType: .Like)
        let dislike = Reaction(username: "Seb", userId: "jhbjh", reactionType: .Dislike)
        let emphasize = Reaction(username: "Seb", userId: "jhbjh", reactionType: .Emphasize)
        let laugh = Reaction(username: "Seb", userId: "jhbjh", reactionType: .Laugh)
        
      //  self.reactions.append(love)
//        self.reactions.append(like)
//        self.reactions.append(dislike)
//        self.reactions.append(emphasize)
//        self.reactions.append(laugh)
        
        //checkCache
        if type == .Video || type == .Audio, exportVideo, let urlString = url, let url = URL(string: urlString) {
            let storedUrl = dictionary["userStoredUrl"] as? String ?? ""
            self.url = CacheManager.getCachedUrl(url, userStoredURL: URL(string: storedUrl), isVideo: type == .Video).absoluteString
        }
    }
    
    func getDictionary() -> [String:Any] {
                
        var dictionary = [
            "id":id,
            "userProfileImageUrl":"",
            "username": "Seb",
            "timestamp": timestamp
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


