//
//  SearchView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct SearchView: View {
    @State var searchText = ""
    @State var inSearchMode = false
    @ObservedObject var viewModel = SearchViewModel()
    
    var body: some View {
        ScrollView {
            SearchBar(text: $searchText, isEditing: $inSearchMode)
                .padding()
            
            ZStack {
                if inSearchMode {
                    //UserListView(viewModel: viewModel, searchtext: $searchText)
                } else {
                    PostGridView(config: .explore)
                }
            }
        }
       
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
