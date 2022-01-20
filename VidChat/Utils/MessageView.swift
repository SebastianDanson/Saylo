//
//  MessageView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI
import MessageUI

struct MessageView: UIViewControllerRepresentable {
    var recipient: String
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var completion: () -> Void
        init(completion: @escaping ()->Void) {
            self.completion = completion
        }
        
        // delegate method
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                   didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
            completion()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator() {} // not using completion handler
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = [recipient]
        vc.body = "Hey, I'm sending you a link to Saylo. Add me so I can send you video messages. \nMy username is \(AuthViewModel.shared.currentUser?.username ?? "")\nhttps://apps.apple.com/ca/app/saylo-video-messenger/id1603124967"
        vc.messageComposeDelegate = context.coordinator
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    typealias UIViewControllerType = MFMessageComposeViewController
}
