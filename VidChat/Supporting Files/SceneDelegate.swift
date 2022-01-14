//
//  SceneDelegate.swift
//  VidChat
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
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        print("sceneWillEnterForeground")
//
//
//
//    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")

        ConversationGridViewModel.shared.updateLastRead()

        AuthViewModel.shared.fetchUser {
            print("1111")
            ConversationGridViewModel.shared.fetchConversations()
        }
        
        CameraViewModel.shared.cameraView.setupSession()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")

        if let chat = ConversationViewModel.shared.chat {
            ConversationService.updateLastVisited(forChat: chat)
        }
        
        CameraViewModel.shared.cameraView.stopSession()
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
