//
//  ImageCell.swift
//  Saylo
//
//  Created by Student on 2021-10-19.
//

import SwiftUI
import Kingfisher

struct ImageCell: View {
    
    let message: Message
    let url: String?
    let image: UIImage?
    let showName: Bool
    
    
    @State var isSaved: Bool
    @State var backGroundColor = Color.systemWhite
    @State var showAlert = false
    @StateObject var viewModel = ConversationViewModel.shared

    init(message: Message, url: String?, image: UIImage?, showName: Bool) {
        self.showName = showName
        self.message = message
        self.image = image
        self.url = url
        self._isSaved = State(initialValue: message.isSaved)
    }
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
           if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: CAMERA_WIDTH, maxWidth: CAMERA_WIDTH, minHeight: 0, maxHeight: CAMERA_HEIGHT)
                    .cornerRadius(12)

            } else if let url = url {
                KFImage(URL(string: url))
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: CAMERA_WIDTH, maxWidth: CAMERA_WIDTH, minHeight: 0, maxHeight: CAMERA_HEIGHT)
                    .cornerRadius(12)
            }
            
            HStack {
                if showName {
                    MessageInfoView(date: message.timestamp.dateValue(), profileImage: message.userProfileImage, name: message.username, showTwoTimeSpeed: false)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 3)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            
            
        }
//        .overlay(
//            
//            ZStack {
//                
//                if viewModel.sendingMessageId == message.id {
//                    
//                    if viewModel.isSending {
//                        ActivityIndicator(shouldAnimate: .constant(true), diameter: 25)
//                        
//                    } else if viewModel.hasSent {
//                        
//                        ZStack {
//                            
//                            Circle()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(message.type == .Audio ? .white : .mainBlue)
//                                .opacity(0.9)
//                            
//                            Image(systemName: "checkmark")
//                                .resizable()
//                                .font(Font.title.weight(.semibold))
//                                .scaledToFit()
//                                .frame(width: 16, height: 16)
//                                .foregroundColor(message.type == .Audio ? .mainBlue : .white)
//
//                        }.transition(.opacity)
//                        
//                    }
//                }
//            }.padding(.trailing, 10)
//            .padding(.bottom, 10),
//            alignment: .bottomTrailing)
//        .onAppear(perform: {
//            setAverageColor()
//        })
        .onTapGesture {
            
            if message.isFromPhotoLibrary {
                ConversationViewModel.shared.selectedImage = image
                ConversationViewModel.shared.selectedUrl = url
                
                withAnimation {
                    ConversationViewModel.shared.showImageDetailView = true
                }
            }
            
        }
        .onLongPressGesture(perform: {
            
            withAnimation {
                if let i = getMessages().firstIndex(where: {$0.id == message.id}) {
                    if getMessages()[i].isSaved {
                        if getMessages()[i].savedByCurrentUser {
                            showAlert = true
                        }
                        
                    } else {
                            ConversationViewModel.shared.updateIsSaved(atIndex: i)
                            isSaved.toggle()
                        }
                    
                }
            }
        })
        .padding(.vertical, 8)
        .overlay(
            ZStack {
                if isSaved {
                    Button {
                        showAlert = true
                    } label: {
                        ZStack {
                            
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundColor(message.savedByCurrentUser ? .mainBlue : .lightGray)
                            
                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash.fill" : "bookmark.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.systemWhite)
                                .frame(width: 18, height: 18)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 18)
                    }.alert(isPresented: $showAlert) {
                        let messages = ConversationViewModel.shared.showSavedPosts ?
                                        ConversationViewModel.shared.savedMessages : ConversationViewModel.shared.messages
                        return savedPostAlert(mesageIndex: messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
                            self.isSaved = isSaved
                        })
                    }
                    
                }
            }
            ,alignment: .bottomTrailing)
        
    }
    
//    func setAverageColor() {
//        if let url = url {
//            let imageView = UIImageView()
//
//            imageView.kf.setImage(with: URL(string: url)) { _ in
//                if let image = imageView.image, let uiColor = image.averageColor {
//                    backGroundColor = Color(uiColor.contrastColor())
//                }
//            }
//        }
//    }
}

