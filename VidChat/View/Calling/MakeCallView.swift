//
//  MakeCallView.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import SwiftUI
import Firebase
import AVFoundation

struct MakeCallView: View {
    
    @StateObject var callsController = CallManager.shared
    @State var isPresentingNewOutgoingCall = false
    @State var isPresentingSimulateIncomingCall = false
    @State var username = ""
    @StateObject var viewModel = MakeCallViewModel.shared
    
    @StateObject var conversationGridViewModel = ConversationGridViewModel.shared
    
    
    // @State var localNumber: String?
    
    var body: some View {
        
        ZStack {
            
            Color.systemWhite.ignoresSafeArea()
            
            VStack {
                
                
                //            if callsController.calls.isEmpty {
                
                CallNavView()
                
                VStack {
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack {
                            
                            ForEach(Array(conversationGridViewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                
                                if !chat.isTeamSaylo && chat.chatMembers.count > 1 {
                                    
                                    Button {
                                        viewModel.createNewOutgoingCall(toChat: conversationGridViewModel.chats[i])
                                    } label: {
                                        UserCallCell(chat: $conversationGridViewModel.chats[i])
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            
                        }
                    }
                    .background(Color.systemWhite)
                    .transition(.move(edge: .bottom))
                }
                //            }
                //            else {
                //                CallView()
                //                    .edgesIgnoringSafeArea(.top)
                //            }
                
            }
        }
        .ignoresSafeArea()
    }
}


struct CallNavView: View {
    
    var body: some View {
        
        ZStack {
            
            Text("Tap a Chat to Call")
                .font(.headline)
            
            HStack {
                
                Button {
                    
                    withAnimation {
                        ConversationGridViewModel.shared.isCalling = false
                        MainViewModel.shared.isCalling = false
                    }
                    
                } label: {
                    
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.systemBlack)
                        .padding(.leading, 16)
                        .padding(.top, -3)
                }
                
                Spacer()
            }
            
        }
        .frame(width: SCREEN_WIDTH, height: 44)
        .padding(.top, TOP_PADDING)
    }
}
