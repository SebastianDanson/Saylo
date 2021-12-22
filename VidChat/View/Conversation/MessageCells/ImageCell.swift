//
//  ImageCell.swift
//  VidChat
//
//  Created by Student on 2021-10-19.
//

import SwiftUI
import Kingfisher

struct ImageCell: View {
    
    let url: String?
    let image: UIImage?
    
    let messageId: String
    let showName: Bool
    let date: Date
    
    let isFromPhotoLibrary: Bool

    @State var isSaved: Bool
    @State var backGroundColor = Color.white
    @State var showAlert = false

    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            if let url = url {
                KFImage(URL(string: url))
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: SCREEN_WIDTH - 10, maxWidth: SCREEN_WIDTH - 10, minHeight: 0, maxHeight: SCREEN_WIDTH * 16/9)
                    .cornerRadius(12)
                    .clipped()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: SCREEN_WIDTH - 10, maxWidth: SCREEN_WIDTH - 10, minHeight: 0, maxHeight: SCREEN_WIDTH * 16/9)
                    .cornerRadius(12)
                    .clipped()
            }
            
            HStack {
                if showName {
                    Image(systemName: "house")
                        .clipped()
                        .scaledToFit()
                        .padding()
                        .background(Color.gray)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    Text("Sebastian")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(backGroundColor)
                    + Text(" • \(date.getFormattedDate())")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(backGroundColor)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 6)
            
            
        }
        .onAppear(perform: {
            setAverageColor()
        })
        .onTapGesture {
            
            if isFromPhotoLibrary {
                ConversationViewModel.shared.selectedImage = image
                ConversationViewModel.shared.selectedUrl = url
                
                withAnimation {
                    ConversationViewModel.shared.showImageDetailView = true
                }
            }
           
        }
        .onLongPressGesture(perform: {
            
            withAnimation {
                if let i = getMessages().firstIndex(where: {$0.id == messageId}) {
                    if getMessages()[i].isSaved {
                        showAlert = true
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
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(white: 0, opacity: 0.3))
                            
                            Image(systemName: ConversationViewModel.shared.showSavedPosts ? "trash" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 18)
                    }.alert(isPresented: $showAlert) {
                        savedPostAlert(mesageIndex: ConversationViewModel.shared.messages.firstIndex(where: {$0.id == messageId}), completion: { isSaved in
                            self.isSaved = isSaved
                        })
                    }
                    
                }
            }
            ,alignment: .bottomTrailing)
            
    }
    
    func setAverageColor() {
        if let url = url {
            let imageView = UIImageView()
            
            imageView.kf.setImage(with: URL(string: url)) { _ in
                if let image = imageView.image, let uiColor = image.averageColor {
                    backGroundColor = Color(uiColor.contrastColor())
                }
            }
        }
    }
}

