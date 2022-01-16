////
////  UnreadMessagesView.swift
////  Saylo
////
////  Created by Sebastian Danson on 2022-01-15.
////
//
//import SwiftUI
//
//struct UnreadMessagesView: View {
//    
//    @StateObject var viewModel = ConversationViewModel.shared
//    
//    var body: some View {
//        
//        ZStack {
//            
//            ConversationFeedView(messages: $viewModel.unreadMessages)
//                .environment(\.colorScheme, .dark)
//                .ignoresSafeArea(edges: .bottom)
//            
//            
//            VStack {
//                
//                ZStack {
//                    HStack {
//                        Button {
//                            ConversationViewModel.shared.showUnreadMessages = false
//                        } label: {
//                            
//                            Image(systemName: "chevron.down")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 20, height: 20)
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 20)
//                        }
//                        
//                        Spacer()
//                    }
//                    
//                    
//                    HStack {
//                        Spacer()
//                        Text("New Messages")
//                            .foregroundColor(.white)
//                            .fontWeight(.medium)
//                        
//                        Spacer()
//                    }
//                }
//                .frame(width: SCREEN_WIDTH, height: 44)
//                .background(Color.black)
//                
//                Spacer()
//            }
//            
//        }
//        
//        
//    }
//}
//
