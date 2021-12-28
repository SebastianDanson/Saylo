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
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            ZStack {
                
                KFImage(URL(string: user.image))
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                
            }.padding(.leading)
            
            Text(user.firstname + " " + user.lastname)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 0) {
                AddButton()
                RemoveButton()
            }
            
        }.frame(height: 60)
    }
}


struct AddButton: View {
    
    var body: some View {
        
        Button {
            
        } label: {
            
            ZStack {
                
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.backgroundGray)
                    .clipShape(Capsule())
                
                Image(systemName: "person.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, -1)
                    .foregroundColor(.black)
                    .frame(width: 16, height: 16)
            }
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

