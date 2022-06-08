//
//  MessageAdOnsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-06.
//

import SwiftUI

struct MessageAdOnsView: View {
    
    @StateObject var viewModel = MainViewModel.shared
    
    var body: some View {
        
        HStack {
            Spacer()
            VStack(spacing: 20) {
                
                Spacer()
                
                Button {
                    withAnimation {
                        MainViewModel.shared.showFilters.toggle()
                    }
                } label: {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: "camera.filters")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(viewModel.showFilters ? Color(.systemBlue) : .white)
                            .frame(width: 25, height: 25)
                        
                        Text("Filters")
                            .foregroundColor(viewModel.showFilters ? Color(.systemBlue) : .white)
                            .font(Font.system(size: 11, weight: .medium))
                    }
                }
                
                Button {
                    withAnimation {
                        MainViewModel.shared.showCaption.toggle()
                    }
                } label: {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: "character.bubble")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(viewModel.showCaption ? Color(.systemBlue) : .white)
                            .frame(width: 25, height: 25)
                        
                        Text("Caption")
                            .foregroundColor(viewModel.showCaption ? Color(.systemBlue) : .white)
                            .font(Font.system(size: 11, weight: .medium))
                    }
                }
                
                
                Spacer()
            }
            .shadow(color: Color(.init(white: 0, alpha: 0.1)), radius: 8, x: 0, y: 4)
            
        }
        .padding(.bottom, TOP_PADDING_OFFSET)
        .padding(.trailing, 8)
    }
}

struct MessageAdOnsView_Previews: PreviewProvider {
    static var previews: some View {
        MessageAdOnsView()
    }
}
