//
//  MessageSendingView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct MessageSendingView: View {
    
    @Binding var isSending: Bool
    @Binding var hasSent: Bool
    
    
    var body: some View {
        
        ZStack {
            
            //            if i == messages.count - 1 {
            
            
            if hasSent {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                        .foregroundColor(.mainBlue)
                        .opacity(0.9)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: MINI_MESSAGE_WIDTH/3, height: MINI_MESSAGE_WIDTH/3)
                        .foregroundColor(.systemWhite)
                    
                }.transition(.opacity)
                
            }
            
            
            
            if isSending {
                
                VStack {
                    
                    Spacer()
                    
                    ZStack {
                        
                        
                        Button {
                            MediaUploader.uploadTask?.cancel()
                            ConversationViewModel.shared.cancelUpload()
                            isSending = false
                        } label: {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: MINI_MESSAGE_WIDTH, height: MINI_MESSAGE_HEIGHT)
                                    .foregroundColor(Color(white: 0, opacity: 0.4))
                                
                                VStack(spacing: 2) {
                                    
                                    Image(systemName: "trash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: MINI_MESSAGE_WIDTH/4, height: MINI_MESSAGE_WIDTH/4)
                                        .foregroundColor(.white)
                                    
                                    Text("Cancel")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12, weight: .semibold))
                                    
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            ActivityIndicatorRectangle(width: MINI_MESSAGE_WIDTH - 8)
                                .transition(.opacity)
                        }
                        
                    }.padding(.bottom, 10)
                }
            }
        }
    }
}
