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
    
            DispatchQueue.main.async {
                
                if ConversationPlayerViewModel.shared.messages.isEmpty {
                    ConversationPlayerViewModel.shared.setMessages()
                }
                
                let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
                let newMessagesArray = defaults?.object(forKey: "messages") as? [[String:Any]] ?? [[String:Any]]()

                        
                if newMessagesArray.count > 0 {
                    ConversationGridViewModel.shared.hasUnreadMessages = true
                }
            }
           
    
        }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        let hasCompletedSignUp = defaults?.bool(forKey: "hasCompletedSignUp")
        
        
        if ConversationPlayerViewModel.shared.messages.isEmpty {
            ConversationPlayerViewModel.shared.setMessages()
        }
        
        AuthViewModel.shared.fetchUser {
            ConversationGridViewModel.shared.fetchConversations()
        }
        
        if AuthViewModel.shared.isSignedIn, hasCompletedSignUp ?? false {
            MainViewModel.shared.cameraView.setupSession()
        }
            
        ConversationGridViewModel.shared.showCachedChats()
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
        if let chat = ConversationViewModel.shared.chat {
            ConversationService.updateLastVisited(forChat: chat)
        }
        
        if ConversationViewModel.shared.showCamera {
            MainViewModel.shared.cancelRecording()
        }
        
        MainViewModel.shared.cameraView.stopSession()
//        MainViewModel.shared.audioRecorder.s
        
        ConversationGridViewModel.shared.setChatCache()
    
        ConversationViewModel.shared.cleanNotificationsArray()
        
        let defaults = UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)
        defaults?.set([[String:Any]](), forKey: "messages")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        ConversationViewModel.shared.removeChat()
        ConversationGridViewModel.shared.showConversation = false
    }
    
    //    func sceneWillResignActive(_ scene: UIScene) {
    //
    //    }
    //    func sceneDidEnterBackground(_ scene: UIScene) {
    //        print("sceneDidEnterBackground")
    //
    //        CameraViewModel.shared.cameraView.stopSession()
    //    }
    
}
