//
//  MakeCallView.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import SwiftUI
import Firebase

struct MakeCallView: View {
    
    @EnvironmentObject var callsController: CallManager
    @State var isPresentingNewOutgoingCall = false
    @State var isPresentingSimulateIncomingCall = false
    @State var username = ""
    @ObservedObject var viewModel = MakeCallViewModel()
    // @State var localNumber: String?
    
    var body: some View {
        VStack {
            
            Group {
                VStack {
                    if !callsController.calls.isEmpty {
                        CallView()
                            .edgesIgnoringSafeArea(.top)
                    } else {
                        Text("Make a call")
                            .bold()
                        
                        LazyVStack(spacing: 12) {
                            
                            ForEach(Array(viewModel.users.enumerated()), id: \.1.id) { i, element in
                                withAnimation {
                                    Button {
                                        createNewOutgoingCall(toUser: viewModel.users[i])
                                    } label: {
                                        Text("\(viewModel.users[i].username)")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.mainBlue)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.ignoresSafeArea()
    }
    
    func createNewOutgoingCall(toUser user: User) {
        guard let currentUser = AuthViewModel.shared.currentUser else {return}
        callsController.startOutgoingCall(of: currentUser.username, pushKitToken: user.pushKitToken)
    }
}
