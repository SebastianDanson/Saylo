//
//  SaveView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI


struct SaveView: View {
    
    var isSaved: Bool
    @Binding var showAlert: Bool
    let index: Int
    
    init(showAlert: Binding<Bool>, isSaved: Bool, index: Int) {
        self.isSaved = isSaved
        self._showAlert = showAlert
        self.index = index
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Spacer()
                
                Button {
                    
                    if !isSaved {
                        MainViewModel.shared.isSaving = true
                        ConversationViewModel.shared.updateIsSaved(atIndex: index)
                    } else {
                        ConversationViewModel.shared.saveToggleIndex = index
                        showAlert = true
                    }
                } label: {
                    
                    ZStack {
                        
                        Color.fadedBlack
                        
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: IS_SMALL_WIDTH ? 16 : 19, height:  IS_SMALL_WIDTH ? 16 : 19)
                            .foregroundColor(Color(.white))
                        
                    }
                    .frame(width:  IS_SMALL_WIDTH ? 28:32, height:  IS_SMALL_WIDTH ? 28:32)
                    .clipShape(Circle())
                    .padding(4)
                    
                }
                
            }
            
            Spacer()
        }
    }
}
