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
                .foregroundColor(.white)
                .padding(.top, 16)
                .padding(.bottom, 1)

            
            HStack(spacing: 4) {
                
                
                Text("Tap")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                
                Image(systemName: "bookmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                
                Text("on Saylo's you want to save")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                
            }
        
            
            Spacer()
        }
     
    }
}

struct NoSavedMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NoSavedMessagesView()
    }
}
