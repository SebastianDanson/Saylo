//
//  ProfileView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    @ObservedObject var viewModel: ProfileViewModel
    
    init(user: User) {
        self.user = user
        self.viewModel = ProfileViewModel(user: user)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ProfileHeaderView(viewModel: viewModel)
                if let id = user.id {
                    PostGridView(config: .profile(id))
                }
            }
        }.padding(.top)
    }
}


