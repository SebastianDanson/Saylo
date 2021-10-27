//
//  ContentView.swift
//  VidChat
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var selectedIndex = 0
    @EnvironmentObject var callManager: CallManager
    
    var body: some View {
        
        Group {
            //if not logged in -> show login
            //else show main interface
//            if !viewModel.isSignedIn {
//                LoginView()
//            } else {
//                if viewModel.currentUser != nil {
                    ConversationView(audioRecorder: AudioRecorder())
//                    MakeCallView()
//                        .environmentObject(AppDelegate.shared.callManager)
//                        .onAppear {
//                            //TODO make this only run once
//                            AppDelegate.shared.askToSendNotifications()
//                        }
                //}
            //}
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

