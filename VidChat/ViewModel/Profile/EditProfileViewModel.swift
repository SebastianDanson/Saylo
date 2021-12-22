//
//  EditProfileViewModel.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import Foundation

class EditProfileViewModel: ObservableObject {
    private let user: User
    
    init(user: User) {
        self.user = user
    }
}
