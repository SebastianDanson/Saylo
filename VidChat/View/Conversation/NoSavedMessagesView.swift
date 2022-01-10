//
//  NoSavedMessagesView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-10.
//

import SwiftUI

struct NoSavedMessagesView: View {
    var body: some View {
        
        VStack {
            
            Spacer()
            Image(systemName: "bookmark.slash.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.mainBlue)
                .frame(width: 100, height: 100)
            
            Text("No Saved Messages")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 1)

            
            Text("Tap and hold a message to save it")
                .foregroundColor(Color(.systemGray))
                .font(.system(size: 20, weight: .medium))
            
            Spacer()
        }
     
    }
}

struct NoSavedMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NoSavedMessagesView()
    }
}
