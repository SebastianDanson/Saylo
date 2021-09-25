//
//  UserListView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI

struct UserListView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @Binding var searchtext: String
    
    private var users: [User] {
        return searchtext.isEmpty ? viewModel.users : viewModel.filteredUsers(searchtext)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                   NavigationLink(
                    destination: LazyView(ProfileView(user: user)),
                    label: {
                        UserCell(user: user)
                            .padding(.leading)
                    })
                }
            }
        }
    }
}
