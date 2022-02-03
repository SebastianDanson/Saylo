//
//  CallManager.swift
//  Saylo
//
//  Created by Student on 2021-10-20.
//

import CallKit
import Combine
import Firebase
import AgoraRtcKit
import SwiftUI

protocol CallManagerDelegate: AnyObject {
    func remoteUserIDsUpdated()
    func remoteUserToggledVideo()
}

final class CallManager: NSObject, ObservableObject {
    
    let callController = CXCallController()
    fileprivate var sessionPool = [UUID: String]()
    
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    var inCall = false
    let tempToken: String? = nil //If you have a token, put it here.
    var callID: UInt = 0 //This tells Agora to generate an id for you. We have user IDs from Firebase, but they aren't Ints, and therefore won't work with Agora.
    var channelName: String?
    weak var delegate: CallManagerDelegate?
    var currentCall: Call?
    var currentChat: Chat?
    
    static var shared = CallManager()
    
    private override init() {}
    
    @Published var remoteUserIDs: [UInt] = [] {
        didSet {
            if remoteUserIDs.count == 0 {
               endCurrentCall()
            } else {
                delegate?.remoteUserIDsUpdated()
            }
        }
    }
    
    func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        }
        return agoraKit!
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: agoraDelegate)
    }
    
    func endCalling() {
        endCurrentCall()
        removeCurrentCall()
        leaveChannel()
        destroyInstance()
        channelName = nil
        agoraKit = nil
        self.currentCall = nil
        self.delegate = nil
        self.remoteUserIDs = [UInt]()
        self.inCall = false
        
        withAnimation {
            ConversationViewModel.shared.showCall = false
        }
    }
    
    // MARK: - Actions
    
    /// Starts a new call with the specified handle and indication if the call includes video.
    /// - Parameters:
    ///   - handle: The caller's phone number.
    ///   - video: Indicates if the call includes video.
    func startCall(handle: String, video: Bool = false) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        
        startCallAction.isVideo = video
        
        let transaction = CXTransaction()
        transaction.addAction(startCallAction)
        
        requestTransaction(transaction)
    }
    
    func startOutgoingCall(of session: String, pushKitToken: String) {
        let handle = CXHandle(type: .phoneNumber, value: session)
        let uuid = pairedUUID(of: session)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.isVideo = true
        
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { (error) in
            if let error = error {
                print("startOutgoingSession failed: \(error.localizedDescription)")
                return
            }
            
            //            let uuidString = payload.dictionaryPayload["UUID"] as? String,
            //            let handle = payload.dictionaryPayload["handle"] as? String,
            //            let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
            //            let uuid = UUID(uuidString: uuidString)
            
            
            let data = ["UUID":uuid.uuidString, "handle":session, "hasVideo": true, "token": pushKitToken] as [String : Any]
            
            Firebase.Functions.functions().httpsCallable("makeCall").call(data) { result, error in
                print(error?.localizedDescription, "FUNCTION ERROR")
            }
        }
    }
    
    /// Ends the specified call.
    /// - Parameter call: The call to end.
    func end(call: Call) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        
        requestTransaction(transaction)
    }
    
    /// Sets the specified call's on hold status.
    /// - Parameters:
    ///   - call: The call to update on hold status for.
    ///   - onHold: Specifies whether the call should be placed on hold.
    func setOnHoldStatus(for call: Call, to onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        
        requestTransaction(transaction)
    }
    
    /// Requests that the actions in the specified transaction be asynchronously performed by the telephony provider.
    /// - Parameter transaction: A transaction that contains actions to be performed.
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction:", error.localizedDescription)
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    // MARK: - Call Management
    
    /// A publisher of active calls.
    @Published private(set) var calls = [Call]()
    
    /// Returns the call with the specified UUID if it exists.
    /// - Parameter uuid: The call's unique identifier.
    /// - Returns: The call with the specified UUID if it exists, otherwise `nil`.
    func callWithUUID(uuid: UUID) -> Call? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else { return nil }
        
        return calls[index]
    }
    
    /// Adds a call to the array of active calls.
    /// - Parameter call: The call  to add.
    func addCall(_ call: Call) {
        calls.append(call)
    }
    
    /// Removes a call from the array of active calls if it exists.
    /// - Parameter call: The call to remove.
    func removeCall(_ call: Call) {
        guard let index = calls.firstIndex(where: { $0 === call }) else { return }
        
        calls.remove(at: index)
    }
    
    func removeCurrentCall() {
        guard let currentCall = currentCall else {
            return
        }
        
        guard let index = calls.firstIndex(where: { $0 === currentCall }) else { return }
        calls.remove(at: index)
    }
    
    func endCurrentCall() {
        guard let index = calls.firstIndex(where: { $0 === currentCall }) else { return }
        end(call: calls[index])
    }
    
    /// Empties the array of active calls.
    func removeAllCalls() {
        calls.removeAll()
    }
    
    func setCallConnected(of session: String) {
        let uuid = pairedUUID(of: session)
        if let call = currentCall(of: uuid), call.isOutgoing, !call.hasConnected, !call.hasEnded {
            AppDelegate.shared.providerDelegate?.provider.reportOutgoingCall(with: uuid, connectedAt: nil)
        }
    }
    
}

extension CallManager {
    func pairedUUID(of session: String) -> UUID {
        for (u, s) in sessionPool {
            if s == session {
                return u
            }
        }
        
        let uuid = UUID()
        sessionPool[uuid] = session
        return uuid
    }
    
    func pairedSession(of uuid: UUID) -> String? {
        return sessionPool[uuid]
    }
    
    func currentCall(of uuid: UUID) -> CXCall? {
        let calls = callController.callObserver.calls
        if let index = calls.firstIndex(where: {$0.uuid == uuid}) {
            return calls[index]
        } else {
            return nil
        }
    }
}

extension CallManager: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        callID = uid
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        remoteUserIDs.append(uid)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == uid }) {
            remoteUserIDs.remove(at: index)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoEnabled enabled: Bool, byUid uid: UInt) {

    }
    
    
    func joinChannel() {
        if getAgoraEngine().getCallId() == nil, let currentCall = currentCall {

            getAgoraEngine().joinChannel(byToken: tempToken, channelId: currentCall.uuid.uuidString, info: nil, uid: callID) { [weak self] (sid, uid, elapsed) in
                self?.inCall = true
                self?.callID = uid
                self?.channelName = currentCall.uuid.uuidString
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                if self.remoteUserIDs.count == 0 {
                    self.endCalling()
                }
            }
        }
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
    }
    
    func destroyInstance() {
        AgoraRtcEngineKit.destroy()
    }
    
    func setUpVideo() {
        getAgoraEngine().enableVideo()
        let configuration = AgoraVideoEncoderConfiguration(size:
                                                            AgoraVideoDimension1280x720, frameRate: .fps30, bitrate: 1710,
                                                           orientationMode: .fixedPortrait)
        getAgoraEngine().setVideoEncoderConfiguration(configuration)
    }
    
    
}
