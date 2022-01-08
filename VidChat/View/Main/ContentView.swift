//
//  ContentView.swift
//  VidChat
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared

    var body: some View {
        
        Group {
            
            //if not logged in -> show landing page
            // else show main interface
            if !viewModel.isSignedIn || !viewModel.hasCompletedSignUp {
                LandingPageView()
            } else {
//                if viewModel.currentUser != nil {
                if conversationViewModel.showCall {
                    CallView().ignoresSafeArea()
                } else {
                    ConversationGridView()
                }
//                }
            }
            
        }
    }
}

