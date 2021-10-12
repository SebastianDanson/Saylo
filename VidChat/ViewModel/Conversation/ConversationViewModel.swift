//
//  ConversationViewModel.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import Foundation
import Firebase

class ConversationViewModel: ObservableObject {
    
    @Published var messages = [Message]()
    @Published var chatId = "Chat"
    
    static let shared = ConversationViewModel()
    

    func addMessage(url: String) {
        
 //       guard let user = AuthViewModel.shared.currentUser else {return}
        
        let dictionary = [
            "chatId": chatId,
            "videoUrl":url,
            "type":"video",
            "userProfileImageUrl":"",
            "username": "Seb",
            "timestamp": Timestamp(date: Date())
        ] as [String: Any]
        
        //let ref = COLLECTION_USERS.addDocument(data: dictionary)

        let message = Message(dictionary: dictionary, id: NSUUID().uuidString)
        self.messages.append(message)
        print("ADDED")
        
    }
}
