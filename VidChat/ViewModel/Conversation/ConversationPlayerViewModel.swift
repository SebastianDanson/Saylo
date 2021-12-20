//
//  ConversationPlayerViewModel.swift
//  VidChat
//
//  Created by Student on 2021-12-19.
//

import Foundation

class ConversationPlayerViewModel: ObservableObject {
    
    @Published var dateString = ""
    
    var dates = [Date]() {
        didSet {
            if let date = dates.first {
                self.dateString = date.getFormattedDate()
            }
        }
    }

    static let shared = ConversationPlayerViewModel()
    private init() {}
}

