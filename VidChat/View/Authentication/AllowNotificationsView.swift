//
//  AllowNotificationsView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-02-10.
//

import Foundation
import SwiftUI

struct AllowNotificationsView: View {
    
    @State var isLargeScale = false
    
    var body: some View {
        
        ZStack {
            
            Color.mainBlue.ignoresSafeArea()

            
            VStack {
                
                Text("Last step! Allow notifications\nto know when you have a message")
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, TOP_PADDING + 60)
                    .foregroundColor(.white)
                
                Text("Saylo is a messaging service, so it \ndoesn't really work without this :)")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                ZStack {
                    
                    Image("AllowNotifications")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270, height: 180)
                        .overlay(
                            
                            HStack(spacing: 0) {
                                
                                Button {
                                    
                                    AuthViewModel.shared.finishSignUp()
                                    
                                } label: {
                                    
                                    ZStack {
                                        
                                    }
                                    .frame(width: 270/2, height: 44)
                                    //                                    .background(Color.red)
                                    
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    
                                    
                                    
                                    Button {
                                        
                                        AppDelegate.shared.askToSendNotifications {
                                            AuthViewModel.shared.finishSignUp()
                                        }
                                        
                                    } label: {
                                        
                                        ZStack {
                                        }
                                        .frame(width: 270/2, height: 44)
                                        .overlay(
                                            Circle().stroke(Color(.systemBlue), lineWidth: 3)
                                                .frame(width: 56, height: 56)
                                                .scaleEffect(isLargeScale ? 1.2 : 1)
                                                .padding(.bottom, -5)
                                                .padding(.trailing, 16)
                                                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: true))
                                                .onAppear(perform: {
                                                    self.isLargeScale = true
                                                })
                                            
                                            , alignment: .bottom
                                        )
                                        //                                        .background(Color.blue)
                                        
                                    }
                                }
                                
                            }
                            , alignment: .bottom
                        )
                    
                }
                
                Spacer()
                
            }
            
        }
        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        
    }
    
}
