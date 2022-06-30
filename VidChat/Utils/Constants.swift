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
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH = UIDevice.current.userInterfaceIdiom == .pad ? SCREEN_HEIGHT * 9/16 : UIScreen.main.bounds.width

let HALF_SCREEN_HEIGHT = SCREEN_HEIGHT/2
let IS_SE = SCREEN_WIDTH < 350

let TOP_PADDING = UIApplication.shared.windows[0].safeAreaInsets.top
let BOTTOM_PADDING = UIApplication.shared.windows[0].safeAreaInsets.bottom

let FEEDVIEW_OFFSET: CGFloat = SCREEN_RATIO > 2 ? -28 : -24
let SCREEN_RATIO = SCREEN_HEIGHT / SCREEN_WIDTH

let IS_SMALL_PHONE = SCREEN_RATIO < 2
let IS_SMALL_WIDTH = SCREEN_WIDTH < 400

//Messages
let TOP_PADDING_OFFSET: CGFloat = TOP_PADDING
let WIDTH_RATIO = IS_SMALL_PHONE ? (IS_SMALL_WIDTH ?  1.43 : 1.44) : 1.6
let MESSAGE_HEIGHT = SCREEN_WIDTH * WIDTH_RATIO

//let CHATS_VIEW_HEIGHT = SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET + 10
//let CHATS_VIEW_SMALL_HEIGHT = CHATS_VIEW_HEIGHT / 2
let CHATS_VIEW_HEIGHT = SCREEN_WIDTH/4 + (IS_SMALL_PHONE ? 12 : BOTTOM_PADDING)
let CHATS_VIEW_SMALL_HEIGHT = CHATS_VIEW_HEIGHT
let MINI_MESSAGE_HEIGHT = IS_SMALL_PHONE ? (IS_SE ? SCREEN_WIDTH / 3.75 : SCREEN_WIDTH/3.6) : SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING - BOTTOM_PADDING - 12
let MINI_MESSAGE_WIDTH = MINI_MESSAGE_HEIGHT * (IS_SMALL_PHONE ? (IS_SE ? 0.82 : 0.8) : 0.73)
let SMALL_PHONE_SAYLO_HEIGHT = IS_SMALL_WIDTH ? SCREEN_WIDTH/6 : SCREEN_WIDTH/5

let CAMERA_WIDTH = UIDevice.current.userInterfaceIdiom == .pad ? SCREEN_WIDTH / 1.4 : SCREEN_RATIO > 2 ? SCREEN_WIDTH : SCREEN_WIDTH - 10
let CAMERA_HEIGHT = SCREEN_RATIO > 2 ? MESSAGE_HEIGHT : CAMERA_WIDTH * 16/10


//Photo
let PHOTO_PICKER_BASE_HEIGHT = SCREEN_WIDTH/4*3 + 20
let PHOTO_PICKER_SMALL_HEIGHT = SCREEN_WIDTH/4*2 + 20

//Video length
let MAX_VIDEO_LENGTH = 600 //in seconds
let CHUNK_TIME = 3.0 //in seconds 

//Call
let TIMEOUT_DURATION = 20




//NSE
let SERVICE_EXTENSION_SUITE_NAME = "group.com.SebastianDanson.saylo"
 
