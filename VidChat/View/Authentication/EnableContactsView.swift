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
            
            Text("Find your friends")
                .font(.system(size: 28, weight: .medium))
               

            Image(systemName: "person.2.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.mainBlue)
                .padding(.top, 16)
                .padding(.bottom, 16)
          
            Text("See which of your contacts are \non Saylo")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.mainGray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            Text("Saylo never stores or shares your contacts.\nWe respect your privacy")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(.mainGray))
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


