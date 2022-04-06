//
//  ContentView.swift
//  Saylo
//
//  Created by Student on 2021-09-23.
//

import SwiftUI
import Firebase
struct ContentView: View {
    
    @StateObject var viewModel = AuthViewModel.shared
    @StateObject var conversationViewModel = ConversationViewModel.shared
    
    var body: some View {
        
        Group {
            
            //if not logged in -> show landing page
            // else show main interface
            if !viewModel.isSignedIn || !viewModel.hasCompletedSignUp {

                NavigationView {
                    LandingPageView()
                        .navigationViewStyle(StackNavigationViewStyle())
                }.navigationViewStyle(StackNavigationViewStyle())


            } else {

                if conversationViewModel.showCall {
                    CallView().ignoresSafeArea()
                } else {
                    NavigationView {
                        MainViewModel.shared.cameraView
                            .ignoresSafeArea()
                            .navigationBarHidden(true)
                    }
                }
            }
            
//            MainViewModel.shared.cameraView
//                .ignoresSafeArea()
            
//            VStack {
//                Spacer()
//                MessageOptionsView()
//            }.background(Color.black)
            
            
//            RecordTimerView()
        }
    }
}

