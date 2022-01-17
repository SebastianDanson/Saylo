//
//  ContactUsViewModel.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-31.
//


import Foundation

class ContactUsViewModel {
   
    func sendMessage(_ message: String) {
        
        guard let user = AuthViewModel.shared.currentUser else {return}
        
        COLLECTION_CONTACTUS.addDocument(data: [
            "username":user.username,
            "name":user.firstName + " " + user.lastName,
            "userId": user.id,
            "message":message,
            "email": user.email
        ])
    }
}
