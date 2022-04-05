//
//  MessageOptionsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-28.
//

import SwiftUI
import Kingfisher

struct MessageOptionsView: View {
    
    let lineGray = Color(red: 220/255, green: 220/255, blue: 220/255)
    let isFromCurrentUser = true
    let message: Message
    
    @State var reactionString = ""

    @State var hasSaved = false
    
    init(message: Message) {
        self.message = message
        
        if message.reactions.isEmpty {
            reactionString = "No Reactions"
        } else {
            self.message.reactions.forEach { reaction in
                switch reaction.reactionType {
                case .Love:
                    reactionString += "\(reaction.name) loved "
                case .Like:
                    reactionString += "\(reaction.name) liked "
                case .Dislike:
                    reactionString += "\(reaction.name) disliked "
                case .Emphasize:
                    reactionString += "\(reaction.name) emphasized "
                case .Laugh:
                    reactionString += "\(reaction.name) laughed "
                }
            }
        }
    }
    
    var body: some View {
        
        
        VStack(spacing: 20) {
            
            Spacer()
            
            VStack {
                
                HStack(spacing: 20) {
                    
                    KFImage(URL(string: message.userProfileImage))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    
                    Text(message.username)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Spacer()
                }
                
                Rectangle()
                    .frame(width: SCREEN_WIDTH, height: 1)
                    .foregroundColor(lineGray)
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.mainBlue)
                            .frame(width: 22, height: 22)
                        
                    }
                    .frame(width: 32, height: 32)
                    
                    Text("\(message.timestamp.dateValue().getFormattedDate())")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    
                    Spacer()
                }
                .padding(.top, 2)
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 22)
                            .foregroundColor(Color(.systemGreen))
                    }
                    .frame(width: 32, height: 32)
                    
                    Text(getSeenByText() ?? "")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                    
                    
                    Spacer()
                }
                
                
                HStack(spacing: 20) {
                                        
                    ZStack {
                        Image(systemName: "face.smiling")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color(.systemOrange))
                    }
                    .frame(width: 32, height: 32)
                    
                    Text(reactionString)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        
                                      
                    Spacer()
                }
                
                Rectangle()
                    .frame(width: SCREEN_WIDTH, height: 1)
                    .foregroundColor(lineGray)
                    .padding(.bottom, 4)
                
                HStack {
                    
                    if isFromCurrentUser {
                        
                        VStack {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color(.systemRed))
                            
                            Text("Delete")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        
                        Image(systemName: hasSaved ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color(.systemBlue))
                        
                        Text(hasSaved ? "Unsave" : "Save")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color(.systemBlue))
                    }
                }
                
            }
            .padding()
            .frame(width: SCREEN_WIDTH)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
        }
        .padding(.bottom, BOTTOM_PADDING)
        .ignoresSafeArea(edges: [.bottom])
    }
    
    func getSeenByText() -> String? {
        
        guard let chat = ConversationViewModel.shared.chat else {
            return nil
        }
        
        guard let uid = AuthViewModel.shared.currentUser?.id ?? UserDefaults.init(suiteName: SERVICE_EXTENSION_SUITE_NAME)?.string(forKey: "userId") else {
            return nil
        }
        
        var seenText = "Seen by"
        
        var isFirst = true
        
        chat.seenLastPost.forEach { userId in
            
            if let chatMember = chat.chatMembers.first(where: {$0.id == userId}), chatMember.id != uid {
                
                if isFirst {
                    seenText += " \(chatMember.firstName)"
                } else {
                    seenText += ", \(chatMember.firstName)"
                }
                
                isFirst = false
            }
        }
        
        return seenText == "Seen by" ? nil : seenText
    }
}

//struct MessageOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageOptionsView()
//    }
//}
