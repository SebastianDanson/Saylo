//
//  Friend.swift
//  VidChat
//
//  Created by Sebastian Danson on 2022-01-01.
//

import Foundation

struct Friend {
    
    //Doc info
    let id: String
    
    //name
    var username: String
    var firstName: String
    var lastName: String

    //profile
    var profileImageUrl: String
    
    //tokens
    let fcmToken: String
    let pushKitToken: String

    
    init(dictionary: [String:Any], id: String) {
        
        //Doc info
        self.id = id

        //name
        self.username = dictionary["username"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        
        //profile
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        //tokens
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        self.pushKitToken = dictionary["pushKitToken"] as? String ?? ""

    }
}
