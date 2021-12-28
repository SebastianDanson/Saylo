//
//  AddFriendsView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-28.
//

import SwiftUI

struct AddFriendsView: View {
    var body: some View {
        
        VStack {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        //                    mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                
                Text("Add Friends")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                
                
                
            }
            .background(Color.white)
            .frame(width: SCREEN_WIDTH, height: 44)
            
            VStack(spacing: 0) {
                
                AddFriendCell(user: ConversationGridViewModel.shared.users[0])
                
            } .frame(width: SCREEN_WIDTH - 40)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color(.init(white: 0, alpha: 0.08)), radius: 16, x: 0, y: 4)
            
            Spacer()
        }
    }
}

struct AddFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendsView()
    }
}
