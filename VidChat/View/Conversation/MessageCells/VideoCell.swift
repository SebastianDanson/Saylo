//
//  VideoCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI

//TODO fix issue when you close camera and u see the whit background of text cell i.e have textcell on screen and open and close camera

struct VideoCell: View {
    
    let message: Message
    @State var showReaction = false
    @State var isSaved: Bool
    @State var showAlert = false
    @State var reactions: [Reaction]
    let videoPlayerView: VideoPlayerView
    
    init(message: Message) {
        self.message = message
        self.reactions = message.reactions
        self.isSaved = message.isSaved
        self.videoPlayerView = VideoPlayerView(url: URL(string: message.url!)!, id: message.id, showName: true, date: message.timestamp.dateValue())
    }
    
    var body: some View {
        
        let gesture = LongPressGesture()
            .onEnded { _ in
                withAnimation {
                    if let i = getMessages().firstIndex(where: {$0.id == message.id}) {
                        if getMessages()[i].isSaved {
                            showAlert = true
                        } else {
                            ConversationViewModel.shared.updateIsSaved(atIndex: i)
                            isSaved.toggle()
                        }
                        
                    }
                }
            }
        
        let addedReactions = AddedReactions(reactions: $reactions)
            .padding(.leading, 16)
            .padding(.bottom, 76)
        
        ZStack {
            
            videoPlayerView
                .gesture(gesture)
            
            VStack {
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    
                    VStack {
                        Spacer()
                        
                        
                        addedReactions
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        
                        if showReaction {
                            ReactionView(messageId: message.id, reactions: $reactions)
                                .transition(.scale)
                        }
                        
                        Button {
                            withAnimation(.linear(duration: 0.2)) {
                                showReaction.toggle()
                            }
                        } label: {
                            
                            ZStack {
                                
                                if showReaction {
                                    Circle()
                                        .frame(width: 46, height: 46)
                                        .foregroundColor(Color(white: 0, opacity: 0.3))
                                }
                                
                                Image(systemName: "face.smiling")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if isSaved {
                            
                            Button {
                                showAlert = true
                            } label: {
                                ZStack {
                                    
                                    Circle()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(white: 0, opacity: 0.3))
                                    
                                    Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                }
                            }.alert(isPresented: $showAlert) {
                                savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
                                    self.isSaved = isSaved
                                })
                            }
                        }
                    }.padding(.trailing, 18)
                        .padding(.bottom, 36)
                }
            }
        }
    }
}


struct AddedReactions: View {
    
    @Binding var reactions: [Reaction]
    
    var body: some View {
        
        if reactions.count > 1 {
        ZStack {
            VStack {
                
                if reactions.contains(where: {$0.reactionType == .Love}) {
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 19, height: 19)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 6)
                    
                }
                
                if reactions.contains(where: {$0.reactionType == .Like}) {
                    
                    Image(systemName: "hand.thumbsup.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 19, height: 19)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                    
                }
                
                if reactions.contains(where: {$0.reactionType == .Dislike}) {
                    
                    Image(systemName: "hand.thumbsdown.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 19, height: 19)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                    
                }
                
                if reactions.contains(where: {$0.reactionType == .Emphasize}) {
                    
                    Image("ExclamationMark")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 20, height: 23)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                }
                
                if reactions.contains(where: {$0.reactionType == .Laugh}) {
                    
                    Image("Haha")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                }
                
            }
            .padding(.vertical, 10 )
            
        }
        .background(Color.mainBlue)
        .clipShape(Capsule())
        
        } else {
            ZStack {
                VStack {
                    
                    if reactions.contains(where: {$0.reactionType == .Love}) {
                        
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 19, height: 19)
                            .padding(.vertical, 0)
                            .padding(.horizontal, 6)
                        
                    }
                    
                    if reactions.contains(where: {$0.reactionType == .Like}) {
                        
                        Image(systemName: "hand.thumbsup.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 19, height: 19)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                        
                    }
                    
                    if reactions.contains(where: {$0.reactionType == .Dislike}) {
                        
                        Image(systemName: "hand.thumbsdown.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 19, height: 19)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                        
                    }
                    
                    if reactions.contains(where: {$0.reactionType == .Emphasize}) {
                        
                        Image("ExclamationMark")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 20, height: 23)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                    }
                    
                    if reactions.contains(where: {$0.reactionType == .Laugh}) {
                        
                        Image("Haha")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                    }
                    
                }
                .padding(.vertical, 10 )
                
            }
            .background(Color.mainBlue)
            .clipShape(Circle())
        }
    }
    
}

struct ReactionView: View {
    
    let viewModel = ConversationViewModel.shared
    let messageId: String
    @Binding var reactions: [Reaction]

    
    var body: some View {
        
        VStack {
            
            Button {
                let reaction = Reaction(username: "Seb", userId: "dsfs", reactionType: .Love)
                reactions.append(reaction)
                viewModel.addReactionToMessage(withId: messageId, reaction: reaction)
            } label: {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                    .padding(.horizontal, 10)
            }

            Button {
                
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                    .padding(.horizontal, 10)
            }
            
            
            Button {
                
            } label: {
                Image(systemName: "hand.thumbsdown.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                    .padding(.top, 6)
                    .padding(.bottom, 3)
                    .padding(.horizontal, 10)
            }
            
           
            Button {
                
            } label: {
                Image("ExclamationMark")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 26, height: 30)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
            }
            
            Button {
                
            } label: {
                Image("Haha")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
            }
           
        }.padding(.vertical, 12)
            .background(Color(white: 0, opacity: 0.3))
            .clipShape(Capsule())
    }
}


struct MessageInfoView: View {
    
    let date: Date
    
    var body: some View {
        
        HStack {
            Image(systemName: "house")
                .clipped()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text("Sebastian")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            + Text(" • \(date.getFormattedDate())")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 26)
    }
}
