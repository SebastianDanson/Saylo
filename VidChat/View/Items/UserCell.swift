//
//  UserCell.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//

import SwiftUI
import Kingfisher

struct UserCell: View {
    let user: User

    var body: some View {
        HStack {
            KFImage(URL(string: user.profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipped()
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(user.fullName)
                    .font(.system(size: 14, weight: .regular))
            }
            
            Spacer()
        }
    }
}

