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
    
    let diameter: CGFloat

    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(lineWidth: max(diameter/20, 4))
                .fill(Color.init(red: 0.96, green: 0.96, blue: 0.96))
                .frame(width: diameter, height: diameter)
            
            Circle()
                .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: max(diameter/20, 4), lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(isCircleRotating ? 360 : 0))
                .frame(width: diameter, height: diameter)
                .onAppear() {
                    
                    if shouldAnimate {
                        withAnimation(Animation
                                        .linear(duration: 1)
                                        .repeatForever(autoreverses: false)) {
                            self.isCircleRotating.toggle()
                        }
                    }
                    //                      withAnimation(Animation
                    //                                      .linear(duration: 1)
                    //                                      .delay(0.5)
                    //                                      .repeatForever(autoreverses: true)) {
                    //                          self.animateStart.toggle()
                    //                      }
                    //                      withAnimation(Animation
                    //                                      .linear(duration: 1)
                    //                                      .delay(1)
                    //                                      .repeatForever(autoreverses: true)) {
                    //                          self.animateEnd.toggle()
                    //                      }
                }
        }
    }
    
}


struct ActivityIndicatorRectangle: View {
    
    @Binding var shouldAnimate: Bool
    @State private var isLoading = false
    let width: CGFloat

       var body: some View {
           ZStack {
    
               RoundedRectangle(cornerRadius: 2)
                   .stroke(Color(.systemGray5), lineWidth: 2)
                   .frame(width: width, height: 2)
    
               RoundedRectangle(cornerRadius: 2)
                   .stroke(Color.mainBlue, lineWidth: 2)
                   .frame(width: width/3, height: 2)
                   .offset(x: isLoading ? (width - width/3)/2 : (-width + width/3)/2, y: 0)
                   .animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: true))
           }
           .onAppear() {
               self.isLoading = true
           }
           .onDisappear() {
               self.isLoading = false
           }
       }
}

