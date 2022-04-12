//
//  MessageOptionsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-28.
//

import SwiftUI
import Kingfisher

struct MessageOptionsView: View {
    
    let isFromCurrentUser = true
    let message: Message
    
    @State var reactionString = ""
    @State var hasSaved: Bool
    
    init(message: Message) {
        self.message = message
        self._hasSaved = State(initialValue: message.isSaved) 
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
                    .frame(height: 1)
                    .foregroundColor(.lineGray)
                    .padding(.top, 4)
                
                VStack(spacing: 3) {
                    
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
                    
                    HStack(spacing: 20) {
                        
                        ZStack {
                            Image(systemName: "person.2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 22)
                                .foregroundColor(Color(.systemGreen))
                        }
                        .frame(width: 32, height: 32)
                        
                        Text(getSeenByText() ?? "Not seen yet")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                        
                        Spacer()
                    }
                    .padding(.bottom, 4)
                    
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
                }
                .padding(.vertical, 4)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.lineGray)
                    .padding(.bottom, 4)
                
                HStack {
                    
                    if isFromCurrentUser {
                        
                        Button {
                            ConversationViewModel.shared.deleteMessage(message: message)
                            
                        } label: {
                            
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
                        
                    }
                    
                    Spacer()
                    
                    Button {
                        if let index = ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}) {
                            ConversationViewModel.shared.updateIsSaved(atIndex: index)
                            self.hasSaved.toggle()
                        }
                    } label: {
                        
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
                
            }
            .padding()
            .frame(width: SCREEN_WIDTH)
            .padding(.bottom, BOTTOM_PADDING)
            .ignoresSafeArea(edges: [.bottom])
            .background(Color.popUpSystemWhite)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .transition(.move(edge: .bottom))
            .onAppear {
                setReactionString()
            }
            .onTapGesture {
                
            }
            
        }
        .background(Color(white: 0, opacity: 0.6))
        .onTapGesture {
            withAnimation {
                MainViewModel.shared.selectedMessage = nil
            }
        }
    }
    
    func setReactionString() {
        
        if message.reactions.isEmpty {
            reactionString = "No Reactions"
        } else {
            message.reactions.forEach { reaction in
                switch reaction.reactionType {
                case .Love:
                    reactionString += "• \(reaction.name) \"loved\" "
                case .Like:
                    reactionString += "• \(reaction.name) \"liked\" "
                case .Dislike:
                    reactionString += "• \(reaction.name) \"disliked\" "
                case .Emphasize:
                    reactionString += "• \(reaction.name) \"emphasized\" "
                case .Laugh:
                    reactionString += "• \(reaction.name) \"laughed "
                }
            }
            
            //remove the first '•'
            reactionString.removeFirst(2)
        }
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
        
        ConversationViewModel.shared.seenLastPost.forEach { userId in
            
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
