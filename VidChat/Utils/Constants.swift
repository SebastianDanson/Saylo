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

let TOP_PADDING = UIApplication.shared.windows[0].safeAreaInsets.top
let BOTTOM_PADDING = UIApplication.shared.windows[0].safeAreaInsets.bottom

let FEEDVIEW_OFFSET: CGFloat = SCREEN_RATIO > 2 ? -28 : -24
let SCREEN_RATIO = SCREEN_HEIGHT / SCREEN_WIDTH

let IS_SMALL_PHONE = SCREEN_RATIO < 2

//Messages
let TOP_PADDING_OFFSET: CGFloat = TOP_PADDING 
let MESSAGE_HEIGHT = SCREEN_WIDTH * 1.5
//let CHATS_VIEW_HEIGHT = SCREEN_HEIGHT - MESSAGE_HEIGHT - TOP_PADDING_OFFSET + 10
//let CHATS_VIEW_SMALL_HEIGHT = CHATS_VIEW_HEIGHT / 2
let CHATS_VIEW_HEIGHT = UIScreen.main.bounds.width/4 + (IS_SMALL_PHONE ? 12 : BOTTOM_PADDING)
let CHATS_VIEW_SMALL_HEIGHT = CHATS_VIEW_HEIGHT
let MINI_MESSAGE_WIDTH = IS_SMALL_PHONE ? SCREEN_WIDTH/7 : max(SCREEN_HEIGHT - MESSAGE_HEIGHT - CHATS_VIEW_SMALL_HEIGHT - TOP_PADDING_OFFSET - 12, SCREEN_WIDTH/5 - 10)
let MINI_MESSAGE_HEIGHT = MINI_MESSAGE_WIDTH
let SMALL_PHONE_SAYLO_HEIGHT = UIScreen.main.bounds.width/5

//Camera

//let CAMERA_SMALL_WIDTH = UIDevice.current.userInterfaceIdiom == .pad ? (SCREEN_WIDTH / 1.4 - 80) : SCREEN_RATIO > 2 ? SCREEN_WIDTH - 24 : SCREEN_WIDTH - 40
//let CAMERA_SMALL_HEIGHT = SCREEN_RATIO > 2 ? CAMERA_SMALL_WIDTH * 16/9 : CAMERA_SMALL_WIDTH * 16/10

let CAMERA_WIDTH = UIDevice.current.userInterfaceIdiom == .pad ? SCREEN_WIDTH / 1.4 : SCREEN_RATIO > 2 ? SCREEN_WIDTH : SCREEN_WIDTH - 10
let CAMERA_HEIGHT = SCREEN_RATIO > 2 ? MESSAGE_HEIGHT : CAMERA_WIDTH * 16/10


//Photo
let PHOTO_PICKER_BASE_HEIGHT = UIScreen.main.bounds.width/4*3 + 20
let PHOTO_PICKER_SMALL_HEIGHT = UIScreen.main.bounds.width/4*2 + 20

//height of extra space above and below camera
let NON_CAMERA_HEIGHT = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 16/9) // Camera aspect ratio is 16/9

//Video length
let MAX_VIDEO_LENGTH = 600 //in seconds

//Call
let TIMEOUT_DURATION = 20




//NSE
let SERVICE_EXTENSION_SUITE_NAME = "group.com.SebastianDanson.saylo"
