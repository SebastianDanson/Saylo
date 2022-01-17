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
    
    private let items = [GridItem(), GridItem(), GridItem()]
    
    // @State var localNumber: String?
    
    var body: some View {
        
        VStack {
            
            
            if callsController.calls.isEmpty {
                
                CallNavView()
                
                VStack {
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            LazyVGrid(columns: items, spacing: 14, content: {
                                ForEach(Array(conversationGridViewModel.chats.enumerated()), id: \.1.id) { i, chat in
                                    ConversationGridCell(chat: $conversationGridViewModel.chats[i])
                                        .flippedUpsideDown()
                                        .scaleEffect(x: -1, y: 1, anchor: .center)
                                        .onTapGesture {
                                            viewModel.createNewOutgoingCall(toChat: conversationGridViewModel.chats[i])
                                        }
                                    
                                }
                            })
                                .padding(.horizontal, 12)
                            
                        }
                    }
                    .background(Color.systemWhite)
                    .padding(.vertical, BOTTOM_PADDING + 20)
                    .flippedUpsideDown()
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .transition(.move(edge: .bottom))
                }
            } else {
                CallView()
                    .edgesIgnoringSafeArea(.top)
                
            }
         
        }.ignoresSafeArea()
    }
}


struct CallNavView: View {
    
    var body: some View {
        
        HStack {
            
            ZStack {
                
                Text("Select Chat To Call")
                    .font(.headline)
                
                HStack {
                    
                    Button {
                        ConversationGridViewModel.shared.isCalling = false
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
            
        }
        .padding(.top, TOP_PADDING)
        .frame(width: SCREEN_WIDTH, height: TOP_PADDING + 40)
        .ignoresSafeArea()
        
    }
}
