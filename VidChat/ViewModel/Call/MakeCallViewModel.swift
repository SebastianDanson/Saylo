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
        guard let chatMember = chat.chatMembers.first(where: {$0.id != currentUser.id}) else {return}
        
        CallManager.shared.currentChat = chat
         
        CallManager.shared.startOutgoingCall(of: currentUser.firstName + " " + currentUser.lastName, pushKitToken: chatMember.pushKitToken)
    }
}
