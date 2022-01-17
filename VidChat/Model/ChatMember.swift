//
//  ChatMember.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-16.
//

import Foundation

class ChatMember {
    
    let id: String
    var firstName: String
    var lastName: String
    var username: String
    var fcmToken: String
    let pushKitToken: String
    let profileImage: String
    let dictionary: [String:Any]
    
    init(dictionary: [String:Any], id: String? = nil) {
        self.dictionary = dictionary
        self.id = dictionary["userId"] as? String ?? id ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        self.pushKitToken = dictionary["pushKitToken"] as? String ?? ""
        self.profileImage = dictionary["profileImage"] as? String ?? ""
    }
    
}


