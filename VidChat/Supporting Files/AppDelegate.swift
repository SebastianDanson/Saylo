//
//  AppDelegate.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import UIKit
import PushKit
import Firebase
import AVFoundation
//import FlurryAnalytics
import gRPC_Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    class var shared: AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    let pushRegistry = PKPushRegistry(queue: .main)
    let callManager = CallManager.shared
    var providerDelegate: ProviderDelegate?
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        FirebaseApp.configure()
        
        Flurry.startSession("WFHSSXFYSQFPR8SPM3ZQ", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
        
        //        let audioSession = AVAudioSession.sharedInstance()
        //            do {
        //                // Set the audio session category, mode, and options.
        //                try audioSession.setCategory(.playAndRecord,  options: [.mixWithOthers,.defaultToSpeaker,.allowBluetooth])
        //                try audioSession.setActive(true)
        //            } catch {
        //                print("Failed to set audio session category.")
        //            }
        
        if Auth.auth().currentUser != nil {
            askToSendNotifications {}
        }
        
        //        try! Auth.auth().signOut()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        guard let handle = url.startCallHandle else {
            print("Could not determine start call handle from URL: \(url)")
            return false
        }
        
        callManager.startCall(handle: handle)
        return true
    }
    
    private func application(_ application: UIApplication,
                             continue userActivity: NSUserActivity,
                             restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        guard let handle = userActivity.startCallHandle else {
            print("Could not determine start call handle from user activity: \(userActivity)")
            return false
        }
        
        guard let video = userActivity.video else {
            print("Could not determine video from user activity: \(userActivity)")
            return false
        }
        
        callManager.startCall(handle: handle, video: video)
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}

// MARK: - PKPushRegistryDelegate
extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02.2hhx", $0) }.joined()
//        print("voip token = \(token)")
        let uid = Auth.auth().currentUser?.uid
        
        if let uid = uid  {
            COLLECTION_USERS.document(uid).updateData(["pushKitToken" : token])
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType, completion: @escaping () -> Void) {
        
        
        let data = payload.dictionaryPayload["data"] as? [String:Any] ?? [String:Any]()
//        print(data, "DATA")
        defer {
            completion()
        }
        
        //        guard type == .voIP,
        //            let uuidString = payload.dictionaryPayload["UUID"] as? String,
        //            let handle = payload.dictionaryPayload["handle"] as? String,
        //            let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
        //            let uuid = UUID(uuidString: uuidString)
        //            else {
        //                return
        //        }
        
        guard type == .voIP,
              let uuidString = data["UUID"] as? String,
              let handle = data["handle"] as? String,
              let hasVideo = data["hasVideo"] as? Bool,
              let uuid = UUID(uuidString: uuidString)
        else {
            return
        }
        //let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        //        AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: handle, hasVideo: hasVideo) { _ in
        //            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        //        }
        displayIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if self.providerDelegate?.pendingCall != nil {
                self.providerDelegate?.provider.reportCall(with: uuid, endedAt: Date(), reason: .unanswered)
            }
        }
    }
    
    // MARK: - PKPushRegistryDelegate Helper
    
    /// Display the incoming call to the user.
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
        
    }
    
    
}


extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func askToSendNotifications(completion: @escaping(() -> Void)) {
        let application = UIApplication.shared
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in
                completion()
            })
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        if let fcmToken = fcmToken {
            
            let dataDict:[String: String] = ["token": fcmToken ?? ""]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
            
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "fcmToken")
            defaults.set(fcmToken, forKey: "fcmToken")
            
//            print(token, "TOKEN", fcmToken, "FCM")
            
            if token == nil {
                AuthViewModel.shared.updateTeamSayloChat(fcmToken: fcmToken)
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        let data = userInfo["data"] as? [String:Any]
        let chatId = data?["chatId"] as? String
        let userId = data?["userId"] as? String
        
        let isFriendRequest = data?["isSentFriendRequest"] as? Bool ?? false
        let acceptedFriendRequest = data?["acceptedFriendRequest"] as? Bool ?? false
        let isLive = data?["isLive"] as? Bool ?? false

        let fromCurrentUser = AuthViewModel.shared.currentUser?.id == userId
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        var notificationArray = defaults?.object(forKey: "notifications") as? [String] ?? [String]()
        
        if let chatId = chatId, ConversationViewModel.shared.chatId != chatId && !notificationArray.contains(chatId) && !fromCurrentUser {
            notificationArray.append(chatId)
            defaults?.set(notificationArray, forKey: "notifications")
            UIApplication.shared.applicationIconBadgeNumber = notificationArray.count
        }
        
        if isFriendRequest {
            AuthViewModel.shared.hasUnseenFriendRequest = true
            AuthViewModel.shared.fetchUser {}
        }
        
        if acceptedFriendRequest {
            AuthViewModel.shared.fetchUser {
                ConversationGridViewModel.shared.fetchConversations(updateFriendsView: true)
            }
        }
        
        if !fromCurrentUser {
            
            if let chatId = chatId, !chatId.isEmpty {
                
                ConversationGridViewModel.shared.fetchConversation(withId: chatId) {
                    
                  
                    if MainViewModel.shared.selectedView != .Saylo, !MainViewModel.shared.isRecording, ConversationGridViewModel.shared.showConversation, ConversationViewModel.shared.liveUsers.count == 0,
                       !ConversationViewModel.shared.watchedStreams.contains(chatId){
                        
                        if let chat = ConversationGridViewModel.shared.chats.first(where: {$0.id == chatId}) {
                            
                            if ConversationViewModel.shared.lastSendingRecordingId == "" {
                                chat.hasUnreadMessage = true
                                ConversationViewModel.shared.setChat(chat: chat)
                            }
                            
                            ConversationViewModel.shared.lastSendingRecordingId = ""                            
                        }
                    }
                    
                    ConversationViewModel.shared.watchedStreams
                        .removeAll(where: {$0 == chatId})
                }
            }
            
            completionHandler([.badge, .banner])
        } else {
            completionHandler([])
        }
        
        completionHandler([.badge, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        let data = userInfo["data"] as? [String:Any]
        let chatId = data?["chatId"] as? String
        //        let chatId = data?["chatId"] as? String
        let isFriendRequest = data?["isSentFriendRequest"] as? Bool ?? false
        //        if let chatid = chatId {
        //
        //            let chats = ConversationGridViewModel.shared.getCachedChats()
        //
        //            if let chat = chats.first(where: { $0.id == chatid }) {
        //                ConversationViewModel.shared.setChat(chat: chat)
        //                ConversationGridViewModel.shared.showConversation = true
        //            }
        //        } else
        
        if isFriendRequest {
            ConversationGridViewModel.shared.showAddFriends = true
        }
        
        if let chatId = chatId {
            DispatchQueue.main.async {

                ConversationGridViewModel.shared.showCachedChats()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let updatedChat = ConversationGridViewModel.shared.chats.first(where: {$0.id == chatId }) {
                        updatedChat.hasUnreadMessage = true
                        ConversationViewModel.shared.setChat(chat: updatedChat)
                        ConversationGridViewModel.shared.showConversation = true

                        
                        
                        //                COLLECTION_CONVERSATIONS.document(updatedChat.id).getDocument { snapshot, _ in
                        //                    if let data = snapshot?.data() {
                        //                        let chat = Chat(dictionary: data, id: updatedChat.id)
                        //
                        //                    }
                        //                }
                        //                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        //                    ConversationViewModel.shared.showMessage(atIndex: updatedChat.lastReadMessageIndex)
                        //                }
                    } 
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    ConversationGridViewModel.shared.chats.first(where: {$0.id == chatId})?.hasUnreadMessage = false
                }
                
//                MainViewModel.shared.startRunning()
            }
        }
        
        completionHandler()
    }
}
