//
//  ContentView.swift
//  VidChat
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var callManager: CallManager
    @StateObject var viewModel = AuthViewModel.shared
    @State var selectedIndex = 0
    
    var body: some View {
        
        Group {
            
            //if not logged in -> show login
            // else show main interface
            if !viewModel.isSignedIn || !viewModel.hasCompletedSignUp {
                LandingPageView()
            } else {
                if viewModel.currentUser != nil {
                    ConversationGridView()
                }
            }
            
        }
    }
}

