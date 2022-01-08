//
//  VideoCell.swift
//  VidChat
//
//  Created by Student on 2021-10-11.
//

import SwiftUI
import MapKit
import Kingfisher

//TODO fix issue when you close camera and u see the whit background of text cell i.e have textcell on screen and open and close camera

struct VideoCell: View {
    
    let message: Message
    @State var showReactions = false
    @State var isSaved: Bool
    @State var showAlert = false
    @State var reactions: [Reaction]
    
//    let videoPlayerView: VideoPlayerView
    
    init(message: Message) {
        self.message = message
        self.reactions = message.reactions
        self.isSaved = message.isSaved
//        self.videoPlayerView =
//        self.videoPlayerView.player.pause()
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
        
        let addedReactions = AddedReactionsContainerView(reactions: $reactions)
            .padding(.leading, 16)
            .padding(.bottom, 76)
        
        ZStack {
            
            VideoPlayerView(url: URL(string: message.url!)!, showName: true, message: message)
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
                        
                        if showReactions {
                            ReactionView(messageId: message.id, reactions: $reactions, showReactions: $showReactions)
                                .transition(.scale)
                        }
                        
                        Button {
                            withAnimation(.linear(duration: 0.2)) {
                                showReactions.toggle()
                            }
                        } label: {
                            
                            ZStack {
                                
                                if showReactions {
                                    Circle()
                                        .frame(width: 46, height: 46)
                                        .foregroundColor(.point3AlphaSystemBlack)
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
                                        .foregroundColor(.point3AlphaSystemBlack)
                                    
                                    Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                }
                            }.alert(isPresented: $showAlert) {
                                savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
                                    withAnimation {
                                        self.isSaved = isSaved
                                    }
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

struct AddedReaction: View {
    
    let image: Image
    let width: CGFloat
    let height: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    
    init(image: Image, width: CGFloat, height: CGFloat, verticalPadding: CGFloat, horizontalPadding: CGFloat) {
        self.image = image
        self.width = width
        self.height = height
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        
        image
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.white)
            .scaledToFit()
            .frame(width: width, height: height)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .transition(.scale)
    }
}

struct AddedReactionsView: View {
    
    @Binding var reactions: [Reaction]
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                if reactions.contains(where: {$0.reactionType == .Love}) {
                    AddedReaction(image: Image(systemName: "heart.fill"), width: 19, height: 19, verticalPadding: 0, horizontalPadding: 6)
                }
                
                if reactions.contains(where: {$0.reactionType == .Like}) {
                    AddedReaction(image: Image(systemName: "hand.thumbsup.fill"), width: 19, height: 19, verticalPadding: 2, horizontalPadding: 6)
                }
                
                if reactions.contains(where: {$0.reactionType == .Dislike}) {
                    AddedReaction(image: Image(systemName: "hand.thumbsdown.fill"), width: 19, height: 19, verticalPadding: 2, horizontalPadding: 6)
                }
                
                if reactions.contains(where: {$0.reactionType == .Emphasize}) {
                    AddedReaction(image: Image("ExclamationMark"), width: 20, height: 23, verticalPadding: 2, horizontalPadding: 6)
                }
                
                if reactions.contains(where: {$0.reactionType == .Laugh}) {
                    AddedReaction(image: Image("Haha"), width: 20, height: 20, verticalPadding: 2, horizontalPadding: 6)
                }
                
            }
            .padding(.vertical, 10 )
            
        }
        .background(Color.mainBlue)
        
    }
}


struct AddedReactionsContainerView: View {
    
    @Binding var reactions: [Reaction]
    
    var body: some View {
        
        if reactions.count > 1 {
            AddedReactionsView(reactions: $reactions).clipShape(Capsule())
        } else {
            AddedReactionsView(reactions: $reactions).clipShape(Circle())
        }
    }
}

struct ReactionView: View {
    
    let viewModel = ConversationViewModel.shared
    let messageId: String
    @Binding var reactions: [Reaction]
    @Binding var showReactions: Bool

    
    var body: some View {
        
        VStack {
            
            Button {
                handleReactionPressed(reactionType: .Love)
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
                handleReactionPressed(reactionType: .Like)
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
                handleReactionPressed(reactionType: .Dislike)
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
                handleReactionPressed(reactionType: .Emphasize)
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
                handleReactionPressed(reactionType: .Laugh)
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
    
    func handleReactionPressed(reactionType: ReactionType) {
        if let index = reactions.firstIndex(where: { $0.userId == "dsfs" && $0.reactionType == reactionType}) {
            let reaction = reactions[index]
            withAnimation {
                reactions.remove(at: index)
            }
            viewModel.removeReactionFromMessage(withId: messageId, reaction: reaction) {}
        } else if let index = reactions.firstIndex(where: {$0.userId == "dsfs"}) {
            let reaction = reactions[index]
            withAnimation {
                reactions[index].reactionType = reactionType
            }
            viewModel.removeReactionFromMessage(withId: messageId, reaction: reaction) {
                viewModel.addReactionToMessage(withId: messageId, reaction: reactions[index])
            }
        } else {
            let reaction = Reaction(messageId: messageId, username: "Seb", userId: "dsfs", reactionType: reactionType)
            withAnimation {
                reactions.append(reaction)
            }
            viewModel.addReactionToMessage(withId: messageId, reaction: reaction)
        }
        
        showReactions = false
    }
}


struct MessageInfoView: View {
    
    let date: Date
    let profileImage: String
    let name: String
    
    var body: some View {
        
        HStack {
            KFImage(URL(string: profileImage))
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            + Text(" • \(date.getFormattedDate())")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
        }
  
    }
}
