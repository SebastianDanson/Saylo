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
                    MessageInfoView(date: message.timestamp.dateValue(), profileImage: message.userProfileImage, name: message.username)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 3)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            
            
        }
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
                        savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == message.id}), completion: { isSaved in
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

