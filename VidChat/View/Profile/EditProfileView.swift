//
//  EditProfileView.swift
//  VidChat
//
//  Created by Student on 2021-09-25.
//

import SwiftUI

struct EditProfileView: View {
    var body: some View {
        VStack {
            HStack {
                Button(action: {}, label: {
                    Text("Cancel")
                })
                
                Spacer()
                
                Button(action: {}, label: {
                    Text("Done").bold()
                })
            }.padding()
            
            Spacer()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
