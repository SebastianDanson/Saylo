//
//  RecordTimerView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-17.
//

import SwiftUI

struct RecordTimerView: View {
    
    @State var timeElapsed  = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("\(timeElapsed/60):\((timeElapsed%60)/10)\(timeElapsed%10)")
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .onReceive(timer) { _ in
                timeElapsed += 1
            }
            .onAppear(perform: {
                self.timeElapsed = 0
                self.timer.upstream.autoconnect()
            })
            .onDisappear {
                self.timer.upstream.connect().cancel()
            }
            .frame(width: 60, height: 28)
            .background(Color.init(white: 0, opacity: 0.4))
            .clipShape(Capsule())
    }
}

