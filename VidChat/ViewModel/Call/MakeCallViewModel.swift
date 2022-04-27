//
//  MakeCallViewModel.swift
//  Saylo
//
//  Created by Student on 2021-10-23.
//

import Foundation


class MakeCallViewModel: ObservableObject {
    
    
    static let shared = MakeCallViewModel()
    private init() {}
    
    
    func createNewOutgoingCall(toChat chat: Chat) {
        
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        let chatMembers = chat.chatMembers.filter({$0.id != currentUser.id})
        
        var count = 0
        var tokens = [String]()
        for chatMember in chatMembers {
            
            COLLECTION_USERS.document(chatMember.id).getDocument { snapshot, _ in
                
                count += 1
                
                if let data = snapshot?.data() {
                    let user = User(dictionary: data, id: chatMember.id)
                    tokens.append(user.pushKitToken)
                    
                    if count == chatMembers.count {
                        CallManager.shared.startOutgoingCall(of: currentUser.firstName + " " + currentUser.lastName, pushKitTokens: tokens)
                    }
                }
            }
        }
    }
}
