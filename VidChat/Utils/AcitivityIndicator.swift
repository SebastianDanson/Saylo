//
//  AcitivityIndicator.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-01-06.
//

import SwiftUI

struct ActivityIndicator: View {
        
    @State private var isCircleRotating = true
    @State private var animateStart = false
    @State private var animateEnd = true
    
    @Binding var shouldAnimate: Bool
    @StateObject var viewModel = ConversationViewModel.shared
    
    let diameter: CGFloat

    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(lineWidth: max(diameter/20, 4))
                .fill(Color.init(red: 0.96, green: 0.96, blue: 0.96))
                .frame(width: diameter, height: diameter)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(viewModel.uploadProgress, 1.0)))
                .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: max(diameter/20, 4), lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: diameter, height: diameter)
               
        }
    }
    
}


struct ActivityIndicatorRectangle: View {
    
    @StateObject var viewModel = ConversationViewModel.shared
    let width: CGFloat

       var body: some View {
           ZStack(alignment: .leading) {
    
               RoundedRectangle(cornerRadius: 2)
                   .stroke(Color(.systemGray5), lineWidth: 2)
                   .frame(width: width, height: 2)
    
               RoundedRectangle(cornerRadius: 2)
                   .stroke(Color.mainBlue, lineWidth: 2)
                   .frame(width: width * viewModel.uploadProgress, height: 2)
                   .animation(.linear)

           }
       }
}

