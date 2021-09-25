//
//  VidChatApp.swift
//  VideoChatApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI
import Firebase

@main
struct VideoChatApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AuthViewModel.shared)
        }
    }
}
