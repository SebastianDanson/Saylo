//
//  EnableContactsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-18.
//

import Contacts
import SwiftUI
import ContactsUI

struct EnableContactsView: View {
    
    let viewModel = ContactsViewModel.shared
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image(systemName: "person.2.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.mainBlue)
            
            Text("Find your friends")
                .font(.system(size: 24, weight: .medium))
                .padding(.top, 16)
                .padding(.bottom, 2)

            Text("See which of your contacts are \non Saylo")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(.systemGray))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                viewModel.requestAccessToContacts { access in
                    
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 64, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
            }

           
        }
        
    }
    
    
}


