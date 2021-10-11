//
//  ChatService.swift
//  VidChat
//
//  Created by Student on 2021-10-08.
//

import Foundation
import Firebase

struct ConversationService {
    static func uploadVideo(withURL url: URL) {
        MediaUploader.uploadVideo(url: url) { url in
            COLLECTION_CONVERSATIONS.document("test").updateData(["posts" : FieldValue.arrayUnion([url])])
        }
    }
}

