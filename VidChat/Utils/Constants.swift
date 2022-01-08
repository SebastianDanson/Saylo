//
//  Constants.swift
//  VidChat
//
//  Created by Student on 2021-09-24.
//

import Foundation
import Firebase
import UIKit


//Firestore collections
let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_SAVED_POSTS = Firestore.firestore().collection("savedMessages")
let COLLECTION_CONVERSATIONS = Firestore.firestore().collection("conversations")
let COLLECTION_CONTACTUS = Firestore.firestore().collection("contactUs")


//Camera

//Photo
let PHOTO_PICKER_BASE_HEIGHT = UIScreen.main.bounds.width/4*3 + 20
let PHOTO_PICKER_SMALL_HEIGHT = UIScreen.main.bounds.width/4*2 + 20

//height of extra space above and below camera
let NON_CAMERA_HEIGHT = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 16/9) // Camera aspect ratio is 16/9

//Call
let TIMEOUT_DURATION = 5

//Screen
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

let BOTTOM_PADDING = UIApplication.shared.windows[0].safeAreaInsets.bottom
let TOP_PADDING = UIApplication.shared.windows[0].safeAreaInsets.top


//NSE
let SERVICE_EXTENSION_SUITE_NAME = "group.com.SebastianDanson.saylo"
