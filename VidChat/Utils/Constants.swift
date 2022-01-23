//
//  Constants.swift
//  Saylo
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



//Screen
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let HALF_SCREEN_HEIGHT = SCREEN_HEIGHT/2

let BOTTOM_PADDING = UIApplication.shared.windows[0].safeAreaInsets.bottom
let TOP_PADDING = UIApplication.shared.windows[0].safeAreaInsets.top

let FEEDVIEW_OFFSET: CGFloat = SCREEN_RATIO > 2 ? -28 : -24
let SCREEN_RATIO = SCREEN_HEIGHT / SCREEN_WIDTH

//Camera
let CAMERA_SMALL_WIDTH = SCREEN_RATIO > 2 ? SCREEN_WIDTH - 40 : SCREEN_WIDTH - 44
let CAMERA_SMALL_HEIGHT = SCREEN_RATIO > 2 ? CAMERA_SMALL_WIDTH * 16/9 : CAMERA_SMALL_WIDTH * 16/10

let CAMERA_WIDTH = SCREEN_RATIO > 2 ? SCREEN_WIDTH : SCREEN_WIDTH - 10
let CAMERA_HEIGHT = SCREEN_RATIO > 2 ? CAMERA_WIDTH * 16/9 : CAMERA_WIDTH * 16/10

//Photo
let PHOTO_PICKER_BASE_HEIGHT = UIScreen.main.bounds.width/4*3 + 20
let PHOTO_PICKER_SMALL_HEIGHT = UIScreen.main.bounds.width/4*2 + 20

//height of extra space above and below camera
let NON_CAMERA_HEIGHT = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 16/9) // Camera aspect ratio is 16/9

//Call
let TIMEOUT_DURATION = 5




//NSE
let SERVICE_EXTENSION_SUITE_NAME = "group.com.SebastianDanson.saylo"
