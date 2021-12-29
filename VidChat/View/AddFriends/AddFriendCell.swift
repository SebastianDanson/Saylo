//
//  AddFriendCell.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI
import Kingfisher

struct AddFriendCell: View {
    
    let user: TestUser
    let addedMe: Bool
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            KFImage(URL(string: user.image))
                .resizable()
                .scaledToFill()
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .padding(.leading, 10)
            
            
            Text(user.firstname + " " + user.lastname)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 0) {
                AddButton(addedMe: addedMe)
                RemoveButton()
            }
            
        }.frame(height: 60)
    }
}


struct AddButton: View {
    
    let addedMe: Bool
    
    var body: some View {
        
        Button {
            
        } label: {
            
            Text(addedMe ? "Confirm" : "Add")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.mainBlue)
                .cornerRadius(4)
            
        }
    }
}

struct RemoveButton: View {
    
    var body: some View {
        
        Button {
            
        } label: {
            
            HStack {
                
                Image("x")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(Color(.systemGray2))
                    .frame(width: 12, height: 12)
                    .padding()
            }
        }
    }
}

