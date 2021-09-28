//
//  ChatCell.swift
//  VidChat
//
//  Created by Student on 2021-09-26.
//

import SwiftUI
import Kingfisher

struct ChatCell: View {
    
    let user: TestUser
    let width = (UIScreen.main.bounds.width-66) / 2
    
    var body: some View {
        
        VStack(alignment: .leading,
               spacing: user.conversationStatus == .none ? -20 : -50) {
            
            KFImage(URL(string: user.image))
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width)
                .cornerRadius(16)
                .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
            
            
            VStack(alignment: .leading,
                   spacing: -12) {
                
                switch user.conversationStatus {
                case .sent:
                    ConversationStatusView(image: "sent",
                                           conversationStatus: user.conversationStatus)
                case .received:
                    ConversationStatusView(image: "received",
                                           conversationStatus: user.conversationStatus)
                case .receivedOpened:
                    ConversationStatusView(image: "opened",
                                           conversationStatus: user.conversationStatus)
                case .sentOpened:
                    ConversationStatusView(image: "seen",
                                           conversationStatus: user.conversationStatus)
                case .none:
                    EmptyView()
                }
                NameView(firstName: user.firstname, lastName: user.lastname)
                    .zIndex(-1)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
            }
               }
    }
}

struct NameView: View {
    let firstName: String
    let lastName: String
    let width = (UIScreen.main.bounds.width-66) / 2
    
    var body: some View {
        Text(firstName)
            .font(.system(size: 15, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.init(white: 1, alpha: 1)))
            .clipShape(Capsule())
    }
}

struct ConversationStatusView: View {
    let image: String
    let isOpened: Bool
    let isSent: Bool
    
    init(image: String, conversationStatus: ConversationStatus) {
        self.image = image
        
        switch conversationStatus {
        case .sent:
            isOpened = false
            isSent = true
        case .received:
            isOpened = false
            isSent = false
        case .receivedOpened:
            isOpened = true
            isSent = false
        case .sentOpened:
            isOpened = true
            isSent = true
        case .none:
            isOpened = false
            isSent = false
        }
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 44, height: 44)
            .scaledToFit()
            .overlay(
                TimeView(isOpened: isOpened, isSent: isSent)
                , alignment: .center)
            .padding(.leading, -2)
            .padding(.bottom, isOpened ? 4 : 0)
    }
}

struct TimeView: View {
    let isOpened: Bool
    let isSent: Bool
    
    var body: some View {
        VStack {
//            if isOpened {
//                LinearGradient(gradient: Gradient(colors: [.mainGreen, .mainBlue]),
//                               startPoint: .top,
//                               endPoint: .bottom)
//                    .mask(
//                        Text("1d").padding(.trailing, isSent ? 9 : 0)
//                            .font(.system(size: 14, weight: .bold))
//                    )
//
//            } else {
                Text("1d").padding(.trailing, isSent ? 9 : 0)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundColor(isOpened ? .gray : .white)
                
           // }
        }
    }
}

struct ChatCell_Previews: PreviewProvider {
    static var previews: some View {
        ChatCell(user: TestUser(image: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%203.23.09%20PM.png?alt=media&token=e1ff51b5-3534-439b-9334-d2f5bc1e37c1", firstname: "Sebastian", lastname: "Danson", conversationStatus: .receivedOpened))
    }
}
