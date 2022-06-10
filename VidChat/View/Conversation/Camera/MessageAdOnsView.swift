//
//  MessageAdOnsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-06.
//

import SwiftUI

struct MessageAdOnsView: View {
    
    @StateObject var viewModel = MainViewModel.shared
    @Binding var selectedFilter: Filter?
    
    var body: some View {
        
        HStack {
            Spacer()
            VStack(spacing: 20) {
                
                Spacer()
                
                Button {
                    withAnimation {
                        MainViewModel.shared.showFilters.toggle()
                        MainViewModel.shared.showCaption = false
                    }
                } label: {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: "camera.filters")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(getFilterIconColor())
                            .frame(width: 25, height: 25)
                        
                        Text(getFilterText())
                            .foregroundColor(getFilterIconColor())
                            .font(Font.system(size: 11, weight: .medium))
                    }
                }
                
                Button {
                    withAnimation {
                        MainViewModel.shared.showCaption.toggle()
                        MainViewModel.shared.showFilters = false
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
    
    func getFilterIconColor() -> Color {
        
        if viewModel.showFilters {
            return Color(.systemBlue)
        }
        
        return  selectedFilter == nil ? .white : Color(.systemPurple)
    }
    
    func getFilterText() -> String {
        
        if let selectedFilter = selectedFilter {
            return selectedFilter.name
        }
        
        return "Filters"
    }
}

//struct MessageAdOnsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageAdOnsView()
//    }
//}
