//
//  PostGridView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct PostGridView: View {
    private let items = [GridItem(), GridItem(), GridItem()]
    private let width = UIScreen.main.bounds.width / 3
    let config: PostGridConfiguration
    
    @ObservedObject var viewModel: PostGridViewModel
    
    init(config: PostGridConfiguration) {
        self.config = config
        self.viewModel = PostGridViewModel(config: config)
    }
    
    var body: some View {
        LazyVGrid(columns: items, spacing: 2,content: {
            ForEach(0..<10) { post in
              //  NavigationLink(
                //    destination: FeedView(),
                  //  label: {
                        //KFImage(URL(string: post.imageUrl))
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: width)
                            .clipped()
                    //})
            }
            
        })
    }
}

