//
//  TextCell.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI

struct TextCell: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "house")
                .clipped()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .frame(width: 28, height: 28)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("Sebastian")
                    .font(.system(size: 14, weight: .semibold))
                Text("Hello, World! My name is seb")
                    .font(.system(size: 16))
            }
        }.padding(.leading, 12)
    }
}

struct TextCell_Previews: PreviewProvider {
    static var previews: some View {
        TextCell()
    }
}
