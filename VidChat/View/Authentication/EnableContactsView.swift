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
    
    @State var canProceed = false
    
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
                .padding(.bottom, 24)
            
            Spacer()
            
            NavigationLink(destination: SetProfileImageView(), isActive: $canProceed) { EmptyView() }
            
            Button {
                viewModel.requestAccessToContacts { access in
                    LandingPageViewModel.shared.isInContactsView = true
                    canProceed = true
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 64, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
            }
            
            
            Text("Saylo never stores or shares your contacts.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.black)
                .padding(.bottom, BOTTOM_PADDING)
                .padding(.top, 8)
                .padding(.bottom, 8)

            
        }

    }
}


