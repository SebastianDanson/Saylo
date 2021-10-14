//
//  Constants.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase
import UIKit

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_SAVED_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_CONVERSATIONS = Firestore.firestore().collection("conversations")


//Camera

//height of extra space above and below camera
let NON_CAMERA_HEIGHT = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 16/9) // Camera aspect ratio is 16/9

