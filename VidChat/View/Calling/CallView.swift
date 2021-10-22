//
//  CallView.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import SwiftUI

struct CallView: View {

    @State private var isMuted: Bool = false
    @EnvironmentObject var callsController: CallManager
    
    let call: Call

    var body: some View {
        VStack {
            Text("Welcome to the call!")
                .bold()
            Spacer()

            VideoCallView(isMuted: $isMuted)

            HStack {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size:64.0))
                    .foregroundColor(isMuted ? Color.yellow : Color.blue)
                    .onTapGesture {
                        isMuted ? (isMuted = false) : (isMuted = true)
                    }
                    .padding()

                Spacer()

                Image(systemName: "phone.circle.fill")
                    .font(.system(size:64.0))
                    .foregroundColor(.red)
                    .padding()
                    .onTapGesture {
                        callsController.removeCall(call)
                    }
            }
            .padding()
        }
    }
}

//struct CallView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallView()
//    }
//}
