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
    let width = UIScreen.main.bounds.width/2.68
    
    var body: some View {
        //  user.conversationStatus == .none ? -20 : -50
        VStack(alignment: .center,
               spacing: 8) {
            
            KFImage(URL(string: user.image))
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width)
                .cornerRadius(width/2)
                .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
            
            
            
            HStack(spacing: 8) {
                switch user.conversationStatus {
                case .sent:
                    ConversationStatusView(image: "sent",
                                           conversationStatus: user.conversationStatus)
                case .received:
                    ConversationStatusView(image: "received",
                                           conversationStatus: user.conversationStatus)
                default:
                    EmptyView()
                }
                
                Text(user.firstname)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 144/255, green: 144/255, blue: 147/255))
            }.padding(.trailing, user.conversationStatus == .none ? 0 : 24)
        }
    }
}

//struct NameView: View {
//    let firstName: String
//    let lastName: String
//    let width = (UIScreen.main.bounds.width-66) / 3
//
//    var body: some View {
//        Text(firstName)
//            .font(.system(size: 15, weight: .medium))
//            .padding(.vertical, 8)
//            .padding(.horizontal, 12)
//            .background(Color(.init(white: 1, alpha: 1)))
//            .clipShape(Capsule())
//    }
//}

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
            .frame(width: 16, height: 16)
            .scaledToFit()
            .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 6, x: 0, y: 4)
        
        //            .overlay(
        //                TimeView(isOpened: isOpened, isSent: isSent)
        //                , alignment: .center)
        //            .padding(.leading, -2)
        //            .padding(.bottom, isOpened ? 4 : 0)
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
            Text("1d").padding(.trailing, isSent ? 8 : 0)
                .font(.system(size: 10, weight: .bold))
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
