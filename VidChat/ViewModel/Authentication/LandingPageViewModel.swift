//
//  LandingPageViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-31.
//

import Foundation


class LandingPageViewModel: ObservableObject {
    
    @Published var showSetNameView = false
    @Published var showSetUsernameView = false
    @Published var showSetProfileImageView = false

    static let shared = LandingPageViewModel()
    
    private init() { }
    
    func setAuthView() {
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        
        if currentUser.firstName.isEmpty || currentUser.lastName.isEmpty {
            showSetNameView = true
        } else if currentUser.username.isEmpty {
            showSetUsernameView = true
        } else if currentUser.profileImageUrl == "" {
            showSetProfileImageView = true
        }
    }
}
