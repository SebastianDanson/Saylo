//
//  ContactCell.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-19.
//

import SwiftUI
import Kingfisher

struct ContactCell: View {
    
    let contact: PhoneContact
    let viewModel = AddFriendsViewModel.shared
    let index: Int
    @State var showMessageComposer = false
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .foregroundColor(getImageColor())
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .padding(.leading, 12)
            
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(contact.name ?? "")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.systemBlack)
                
                Text(getSubtitleText())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                
            }
            
            Spacer()
            
            
            Button {
                showMessageComposer = true
            } label: {
                InviteButton().padding(.trailing, 16)
            }
            .sheet(isPresented: $showMessageComposer) {
                MessageView(recipient: contact.phoneNumber.first ?? contact.email.first ?? "")
                    .ignoresSafeArea()
            }
            
        }
        .frame(height: 60)
        
    }
    
    func getSubtitleText() -> String {
        contact.phoneNumber.first ?? contact.email.first ?? ""
    }
    
    func getImageColor() -> Color {
        
        switch index%11 {
            
        case 0: return Color(.systemRed)
        case 1: return Color(.systemOrange)
        case 2: return Color(.systemYellow)
        case 3: return Color(.systemGreen)
        case 4: return .systemMint
        case 5: return Color(.systemTeal)
        case 6: return .systemCyan
        case 7: return Color(.systemBlue)
        case 8: return Color(.systemIndigo)
        case 9: return Color(.systemPurple)
        case 10: return Color(.systemPink)
        default: return .mainBlue
            
        }
        
    }
}


struct InviteButton: View {
    
    
    
    var body: some View {
        
        Text("Invite")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.mainBlue)
            .cornerRadius(4)
        
    }
    
}

