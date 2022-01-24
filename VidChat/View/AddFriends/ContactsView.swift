//
//  ContactsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-22.
//

import SwiftUI

struct ContactsView: View {
    
    let viewModel = ContactsViewModel.shared
    
    @State var canAccessContacts: Bool
    
    init() {
        
        if viewModel.getPhoneContacts() != nil {
            self._canAccessContacts = State(initialValue: true)
        } else {
            self._canAccessContacts = State(initialValue: false)
        }
    }
    
    var body: some View {
        
        ZStack {
            
            if canAccessContacts {
                AddFriendsView()
            } else {
                AllowContactsView()
            }
        }.onAppear {
            checkContactAccess()
        }
    }
    
    func checkContactAccess() {
        if viewModel.getPhoneContacts() != nil {
            self.canAccessContacts = true
        } else {
            self.canAccessContacts = false
        }
    }
}


struct AllowContactsView: View {
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 24) {
            
            ZStack {
                
                HStack {
                    
                    Button {
                        
                        withAnimation {
                            ConversationGridViewModel.shared.showFindFriends = false
                        }
                        
                    } label: {
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.systemBlack)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                }
                .frame(height: 44)
                
                Text("All Contacts")
                    .foregroundColor(.systemBlack)
                    .fontWeight(.semibold)
                
            }
            .frame(width: SCREEN_WIDTH, height: 44)
            .padding(.top, TOP_PADDING)
            
            
            Text("Please allow Saylo to access your contacts \nin Settings. We will not store or share \nyour contacts")
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.center)
                .frame(width: SCREEN_WIDTH)
            
            
            Text("Tap \"Open Settings\" and turn on Contacts:")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.mainGray)
                .padding(.top, 32)
            
            Image("EnableContacts")
                .resizable()
                .scaledToFit()
                .frame(width: SCREEN_WIDTH - 64)
                .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 16, x: 0, y: 4)
            
            
            
            Spacer()
            
            Button {
                openSettings()
            } label: {
                
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: SCREEN_WIDTH - 92, height: 50)
                    .background(Color.mainBlue)
                    .clipShape(Capsule())
                    .padding(.bottom, BOTTOM_PADDING + 64)
                
            }
            
        }
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        .ignoresSafeArea()
        .background(Color.systemWhite)
    }
    
    func openSettings() {
        
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
