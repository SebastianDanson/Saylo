//
//  SelectUsersPopUpView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-04.
//

import SwiftUI

struct SelectUsersPopUpView: View {
    
    @StateObject var viewModel = ConversationGridViewModel.shared
    @State var height = SCREEN_WIDTH / 2.1 + (60)
    
    private let items = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                LazyVGrid(columns: items, spacing: 14, content: {
                    ForEach(Array(viewModel.chats.enumerated()), id: \.1.id) { i, chat in
                        ConversationGridCell(chat: $viewModel.chats[i], selectedChatId: .constant(""), textColor: .systemWhite)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.15)) {
                                    viewModel.toggleSelectedChat(chat: chat)
                                }
                            }
                    }
                })
                    .padding(.horizontal, 12)
                
            }
        }
        .frame(width: SCREEN_WIDTH, height: height)
        .padding(.vertical, 16)
        .background(Color(white: 0.1, opacity: 0.9))
        .cornerRadius(25)
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom))
    }
}


