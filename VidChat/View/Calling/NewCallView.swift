//
//  NewCallView.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import SwiftUI

struct NewCallView: View {
    
    struct NewCallDetails {
        var handle = ""
        var isVideo = false
        var delay = 0
        
        var isValid: Bool {
            handle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var callsController: CallManager
    @State private var newCallDetails = NewCallDetails(delay: 5)
    @State var remoteNumber = ""
    let localNumber: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    HStack {
                        Text("Destination")
                        
                        TextField("Handle", text: $newCallDetails.handle)
                            .keyboardType(.emailAddress)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Video Call")
                        Toggle(isOn: $newCallDetails.isVideo, label: { EmptyView() })
                    }
                    
                    TextField("Name", text: $remoteNumber)
                    
                    if !isOutgoing {
                        HStack {
                            Text("Delay \(newCallDetails.delay) seconds")
                            Stepper(value: $newCallDetails.delay, in: 0...100, label: { EmptyView() })
                        }
                    }
                }
            }
            .navigationBarTitle(titleText, displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: dialButton)
        }
    }
    
    var titleText: Text {
        Text(isOutgoing ? "New Outgoing Call" : "Simulate Incoming Call")
    }
    
    var cancelButton: some View {
        Button(action: cancelButtonAction) {
            Text("Cancel")
        }
    }
    
    var dialButton: some View {
        Button(action: dialButtonAction) {
            Text("Dial")
        }
        .disabled(!newCallDetails.isValid)
    }
    
    /// Indicates if the call is outgoing.
    let isOutgoing: Bool
    
    /// Creates a new call based on if the call is outgoing or incoming.
    func dialButtonAction() {
        if isOutgoing {
//            sendInvitation(remote: remoteNumber)
            createNewOutgoingCall(with: newCallDetails)
//            print(remoteNumber, "NUMBER")
//            AgoraRtm.shared().kit?.queryPeerOnline(remoteNumber, success: { status in
//                switch status {
//                case .online:     // sendInvitation(remote: remoteNumber)
//                    print("ONLINE")
//                case .offline:     print("OFFLINE")
//                case .unreachable: print("UNREACHABLE")
//                @unknown default:  fatalError("queryPeerOnline")
//                }
//            }, fail: { error in
//                print(error.localizedDescription, "FAILURE")
//            })
        } else {
            simulateIncomingCall(with: newCallDetails)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // rtm send invitation
    func sendInvitation(remote: String) {
//        let channel = "\(localNumber)-\(remoteNumber)-\(Date().timeIntervalSinceReferenceDate)"
//        print("THIS WORKED")
//        AgoraRtm.shared().inviter!.sendInvitation(peer: remoteNumber, extraContent: channel, accepted: {
//          //  vc?.close(.toVideoChat)
//            print("THIS WORKED SUCCESS")
//
//            //self?.appleCallKit.setCallConnected(of: remote)
//
//            AppDelegate.shared.callManager.setCallConnected(of: remote)
//
//            guard let remote = UInt(remoteNumber) else {
//                fatalError("string to int fail")
//            }
//
//            var data: (channel: String, remote: UInt)
//            data.channel = channel
//            data.remote = remote
//          //  self?.performSegue(withIdentifier: "DialToVideoChat", sender: data)
//
//        }, refused: {
//            print("REFUSED")
//        }) { (error) in
//            print("DEBUG ERROR 1 " + error.localizedDescription)
//        }
    }
    
    /// Cancels the call and dismisses this view.
    func cancelButtonAction() {
        presentationMode.wrappedValue.dismiss()
    }
    
    /// Creates a new outgoing call with the specified details.
    /// - Parameter newCallDetails: The call details, including the caller's phone number and if the call includes video
    func createNewOutgoingCall(with newCallDetails: NewCallDetails) {
        
        callsController.startOutgoingCall(of: newCallDetails.handle)
    }
    
   
    
    /// Simulates an incoming call with the specified details.
    /// - Parameter newCallDetails: The call details, including the caller's phone number and if the call includes video
    func simulateIncomingCall(with newCallDetails: NewCallDetails) {
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + Double(newCallDetails.delay)) {
            AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: newCallDetails.handle, hasVideo: newCallDetails.isVideo) { _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
    }
    
}
