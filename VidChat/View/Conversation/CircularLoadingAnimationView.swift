//
//  CircularLoadingAnimationView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-13.
//

import SwiftUI

struct CircularLoadingAnimationView: View {
    
    @State private var isLoading = false
    let dimension: CGFloat
    
    var body: some View {
        ZStack {
            
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(Color.green, lineWidth: 6)
                .frame(width: dimension, height: dimension)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear() {
                    self.isLoading = true
                }
        }
    }
}
