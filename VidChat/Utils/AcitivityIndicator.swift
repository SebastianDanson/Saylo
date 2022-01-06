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
                .stroke(lineWidth: 5)
                .fill(Color.init(red: 0.96, green: 0.96, blue: 0.96))
                .frame(width: diameter, height: diameter)
            
            Circle()
                .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
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

