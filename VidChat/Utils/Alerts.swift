//
//  Alerts.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI

func savedPostAlert(mesageIndex i: Int?, completion: @escaping((Bool) -> Void)) -> Alert {
    return Alert(
        title: Text(ConversationViewModel.shared.showSavedPosts ? "Delete Message?" : "Unsave Message?"),
        message: Text(ConversationViewModel.shared.showSavedPosts ? "The message with be deleted permanently" : ""),
        primaryButton: .default(
            Text("Cancel"),
            action: {
                completion(true)
            }
        ),
        secondaryButton: ConversationViewModel.shared.showSavedPosts ? .destructive(
            Text("Delete"),
            action: {
                if let i = i {
                    ConversationViewModel.shared.updateIsSaved(atIndex: i)
                    completion(false)
                }
            }
        ) : .default(
            Text("Unsave"),
            action: {
                if let i = i {
                    ConversationViewModel.shared.updateIsSaved(atIndex: i)
                    completion(false)
                }
            }
        )
    )
}


func videoTooLongAlert() -> Alert {
    Alert(
       title: Text("Video Length Is Too Long"),
       message: Text("Videos must be under 60 seconds to send"),
       dismissButton: .default(
           Text("OK"),
           action: {}
       )
   )
}


func allowPhotosAlert() -> Alert {
    
    return Alert(
        title: Text("Enable Photo Access"),
        message: Text("You must enable photo access to send photos"),
        primaryButton: .default(
            Text("Cancel"),
            action: {
                withAnimation {
                    ConversationViewModel.shared.showPhotos = false
                }
            }
        ),
        
        secondaryButton: .default(
            Text("Enable"),
            action: {
                PhotosViewModel.shared.openSettings()
            }
        )
    )
}

