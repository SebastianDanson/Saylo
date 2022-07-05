//
//  SceneDelegate.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Use a UIHostingController as window root view controller
        let contentView = ContentView()
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    ////
    func sceneWillEnterForeground(_ scene: UIScene) {
        
        //        DispatchQueue.main.async {
        //
        //            let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        //            let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()
        //
        //            if newMessagesArray.count > 0 {
        //                ConversationGridViewModel.shared.hasUnreadMessages = true
        //            }
        //        }
        
        DispatchQueue(label: "cache").async {
            ConversationGridViewModel.shared.showCachedChats()
            ConversationGridViewModel.shared.updateFriendsChats()
        }
        
        
        if let selectedFilterName = UserDefaults.standard.string(forKey: "selectedFilter") {
            ConversationViewModel.shared.selectedFilter = Filter.allCases.first(where: {$0.name == selectedFilterName})
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        //        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        //        let hasCompletedSignUp = defaults?.bool(forKey: "hasCompletedSignUp")
        
        
        //        if ConversationPlayerViewModel.shared.messages.isEmpty {
        //            ConversationViewModel.shared.setMessages()
        //        }
        
        
        DispatchQueue(label: "api").async {
            AuthViewModel.shared.fetchUser {
                ConversationGridViewModel.shared.fetchConversations()
            }
        }
        
        //        if AuthViewModel.shared.isSignedIn, hasCompletedSignUp ?? false {
        //            MainViewModel.shared.cameraView.setupSession()
        //        }
        
        //        MainViewModel.shared.cameraView.setupSession()
        
        //        MainViewModel.shared.cameraView.cameraView.setupSession()
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
        
        if ConversationViewModel.shared.showCamera {
            MainViewModel.shared.cancelRecording()
        }
        
        ConversationGridViewModel.shared.setChatCache()
        ConversationViewModel.shared.cleanNotificationsArray()
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        defaults?.set([[String:Any]](), forKey: "messages")
        
        ConversationViewModel.shared.removeChat()
        ConversationGridViewModel.shared.showConversation = false
        
        ConversationViewModel.shared.leaveChannel()
        
        
        if ConversationViewModel.shared.sendingLiveRecordingId == AuthViewModel.shared.getUserId() {
            ConversationViewModel.shared.setSendingLiveRecordingId(nil)
        }
        
        if CallManager.shared.inCall || ConversationViewModel.shared.joinedCallUsers.contains(AuthViewModel.shared.getUserId())  {
            CallManager.shared.endCalling()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        ConversationViewModel.shared.removeChat()
    }
    
    //    func sceneWillResignActive(_ scene: UIScene) {
    //
    //    }
    //        func sceneDidEnterBackground(_ scene: UIScene) {
    //            ConversationGridViewModel.shared.updateFriendsChats()
    //        }
    
}
