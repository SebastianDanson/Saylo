//
//  Alerts.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-22.
//

import SwiftUI

func removeGroupAlert() -> Alert {
    let chat: Chat = ConversationViewModel.shared.chat ?? ConversationGridViewModel.shared.selectedSettingsChat!
    let viewModel = ChatSettingsViewModel.shared
    
    let removeGroupAlert = Alert(
        title: Text("Are you sure you want to \(chat.isDm ? "remove" : "leave") \(chat.name)?"),
        message: nil,
        primaryButton: .default(
            Text("Cancel"),
            action: {
                
            }
        ),
        secondaryButton: .destructive(
            Text("Leave"),
            action: {
                
                if chat.isDm {
                    viewModel.removeFriend(inChat: chat)
                } else {
                    viewModel.leaveGroup(chat: chat)
                }
                
                withAnimation {
                    MainViewModel.shared.settingsChat = nil
//                        ConversationViewModel.shared.hideChat = true
                    ConversationGridViewModel.shared.showConversation = false
                    ConversationGridViewModel.shared.selectedSettingsChat = nil
                }
            }
        )
    )
    
    return removeGroupAlert
}
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

