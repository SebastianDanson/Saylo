//
//  LazyView.swift
//  Saylo
//
//  Created by Student on 2021-09-25.
//

import SwiftUI

struct LazyView<Content:View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping() -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
