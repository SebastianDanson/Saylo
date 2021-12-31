//
//  LandingPageView.swift
//  VidChat
//
//  Created by Sebastian Danson on 2021-12-30.
//

import SwiftUI

struct LandingPageView: View {
    

    var body: some View {
        
        NavigationView {
                                        
                VStack {
                    
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .padding(.top, TOP_PADDING + SCREEN_HEIGHT/5)
                    
                    Spacer()
                    
                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        
                        Text("Sign Up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.mainBlue)
                            .frame(width: SCREEN_WIDTH - 92, height: 50)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    
                    NavigationLink {
                        LoginView()
                            .navigationBarBackButtonHidden(true)                        
                    } label: {
                        
                        Text("Log in")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: SCREEN_WIDTH - 92, height: 50)
                    }.padding(.bottom, 40)
        
            }
            .frame(width: SCREEN_HEIGHT, height: SCREEN_HEIGHT)
            .background(Color.mainBlue)
            .ignoresSafeArea()
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
