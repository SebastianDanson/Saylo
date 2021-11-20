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
    
    @State var isSaved: Bool
    @State var backGroundColor = Color.white
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            if let url = url {
                KFImage(URL(string: url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
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
            .padding(12)
            
            
        }
        .onAppear(perform: {
            print("0")
            setAverageColor()
        })
        .onTapGesture {}
        .onLongPressGesture(perform: {
            
            withAnimation {
                if let i = ConversationViewModel.shared.messages
                    .firstIndex(where: {$0.id == messageId}) {
                    ConversationViewModel.shared.messages[i].isSaved.toggle()
                    isSaved.toggle()
                }
            }
        })
        .overlay(
            ZStack {
                
                if isSaved {
                    Image(systemName: "bookmark.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.mainBlue)
                        .frame(width: 36, height: 24)
                        .padding(.leading, 8)
                        .transition(.scale)
                }
            }
            ,alignment: .topTrailing)
        
        
        //TODO set max height for images
    }
    
    //    func setAverageColor() {
    //        if let urlString = url, let url = URL(string: urlString) {
    //
    //
    //            let task = URLSession.shared.dataTask(with: url) { data, response, error in
    //                guard let data = data, error == nil else { return }
    //                let image = UIImage(data: data)
    //
    //                if let image = image, let uiColor = image.averageColor {
    //                    backGroundColor = Color(uiColor.contrastColor())
    //                }
    //            }
    //
    //            task.resume()
    //
    //        }
    //    }
    
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

