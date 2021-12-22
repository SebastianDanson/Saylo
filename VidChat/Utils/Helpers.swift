//
//  Helpers.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-22.
//

import Foundation

func getMessages() -> [Message] {
    return ConversationViewModel.shared.showSavedPosts ? ConversationViewModel.shared.savedMessages : ConversationViewModel.shared.messages
}
