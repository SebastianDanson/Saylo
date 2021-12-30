//
//  AddFriendsViewModel.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-29.
//


import SwiftUI

class AddFriendsViewModel: ObservableObject {
    
    @Published var scrollViewContentOffset = CGFloat(0)
    @Published var allowGesture = false
    @Published var isSearching: Bool = false
        
    static let shared = AddFriendsViewModel()
    
    private init() {}
    
}
