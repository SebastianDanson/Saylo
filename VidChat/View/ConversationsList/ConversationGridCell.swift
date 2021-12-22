//
//  ChatCell.swift
//  VidChat
//
//  Created by Student on 2021-09-26.
//

import SwiftUI
import Kingfisher

struct ConversationGridCell: View {
    
    @ObservedObject var user: TestUser
    let width = UIScreen.main.bounds.width/4.2
    let textColor = Color(red: 136/255, green: 137/255, blue: 141/255)
    
    var body: some View {
        //  user.conversationStatus == .none ? -20 : -50
        ZStack(alignment:.top) {
            VStack(alignment: .center,
                   spacing: 6) {
                
                KFImage(URL(string: user.image))
                    .resizable()
                    .scaledToFill()
                    .background(Color(.systemGray))
                    .frame(width: width, height: width)
                    .cornerRadius(width/2)
                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                
                
                Text(user.firstname)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(textColor)
            }.overlay(
                ZStack {
                    if user.isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .background(Circle().frame(width: 30, height: 30).foregroundColor(.white))
                            .scaledToFit()
                            .foregroundColor(.mainBlue)
                            .transition(.scale)
                        //                    .shadow(color: Color(.init(white: 0, alpha: 0.15)), radius: 16, x: 0, y: 20)
                    }
                }
                , alignment: .topLeading
                
            )
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

//struct ChatCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatCell(user: TestUser(image: "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%203.23.09%20PM.png?alt=media&token=e1ff51b5-3534-439b-9334-d2f5bc1e37c1", firstname: "Sebastian", lastname: "Danson", conversationStatus: .receivedOpened))
//    }
//}
