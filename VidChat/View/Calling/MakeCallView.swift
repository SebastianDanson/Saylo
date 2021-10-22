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
    @State var localNumber: String?
    
    var body: some View {
        NavigationView {
            Group {
                VStack {
                if !callsController.calls.isEmpty {
                    CallView(call: callsController.calls.last!)
                }
                    Text(localNumber ?? "")
                }
            }
        }.onAppear {

            
            let rtm = AgoraRtm.shared()
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/rtm.log"
            rtm.setLogPath(path)
            
            
            // create local number
            let rand = arc4random_uniform(UInt32(9999 + 1 - 1000)) + 1000
            localNumber = "\(rand)"
            
            // rtm login
            guard let localNumber = localNumber else {
                fatalError("localNumber nil")
            }
            
            guard let kit = AgoraRtm.shared().kit else {
                print("NOI KIT")
                return
            }
            
            kit.login(account: localNumber, token: nil) {
                print("SUCCESS")
            } fail: { error in
                print("ERROR \(error.localizedDescription)")
            }

        }
    }

    /// Returns an HStack containing buttons to initiate outgoing and simulated incoming calls.
    var newCallButtons: some View {
        HStack {
            Button(action: { self.isPresentingNewOutgoingCall = true }) {
                Image(systemName: "phone.fill.arrow.up.right")
            }
            .sheet(isPresented: self.$isPresentingNewOutgoingCall) {
                NewCallView(localNumber: localNumber!, isOutgoing: true)
                    .environmentObject(self.callsController)
            }
            .padding(.trailing)

            Button(action: { self.isPresentingSimulateIncomingCall = true }) {
                Image(systemName: "phone.fill.arrow.down.left")
            }
            .sheet(isPresented: self.$isPresentingSimulateIncomingCall) {
                NewCallView(localNumber: localNumber!, isOutgoing: false)
                    .environmentObject(self.callsController)
            }
            .padding(10)
        }
    }

}
