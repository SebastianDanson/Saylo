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
//                    ConversationView()
//            ConversationGridView()
            ProfileView(user: TestUser(image: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%202.54.09%20PM.png?alt=media&token=0a1b499c-a2d9-416f-ab99-3f965939ed66", firstname: "Sebastian", lastname: "Danson", conversationStatus: .received))
                .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                .background(Color.backgroundGray)

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

