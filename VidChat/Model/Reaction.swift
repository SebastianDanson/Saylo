//
//  Reaction.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-24.
//

import Foundation


enum ReactionType {
    
    case Love, Like, Dislike, Emphasize, Laugh
    
   static func getReactionType(fromString reactionString: String) -> ReactionType {
        switch reactionString {
        case "love":
            return .Love
        case "like":
            return .Like
        case "dislike":
            return .Dislike
        case "emphasize":
            return .Emphasize
        case "laugh":
            return .Laugh
        default:
            print("ERROR: Inproper reaction")
            return .Love
        }
    }
    
    func getString() -> String {
        
        switch self {
            
        case .Love:
            return "love"
        case .Like:
            return "like"
        case .Dislike:
            return "dislike"
        case .Emphasize:
            return "emphasize"
        case .Laugh:
            return "laugh"
            
        }
    }
}

struct Reaction {
    
    var messageId: String
    let username: String
    let userId: String
    var reactionType: ReactionType
    
    func getDictionary() -> [String:Any] {
        ["messageId":messageId, "username":username, "userId":userId, "reactionType":reactionType.getString()]
    }
}


