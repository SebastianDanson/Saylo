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
}

struct Reaction {
    let username: String
    let userId: String
    let reactionType: ReactionType
}


