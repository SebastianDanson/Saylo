//
//  ContentView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var selectedIndex = 0
    
    var body: some View {
        
        Group {
            //if not logged in -> show login
            //else show main interface
            
//            if viewModel.currentUser == nil {
//                LoginView()
//            } else {
//                if viewModel.currentUser != nil {
                    ConversationView()
//                }
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
