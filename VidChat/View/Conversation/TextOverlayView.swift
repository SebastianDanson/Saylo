//
//  TextOverlayView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-06-05.
//

import SwiftUI

struct TextOverlayView: View {
    
    @StateObject var viewModel = TextOverlayViewModel.shared
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
//    @State private var offset = CGSize.zero
    @State private var location: CGPoint = CGPoint(x: SCREEN_WIDTH/2, y: MESSAGE_HEIGHT/2 + TOP_PADDING_OFFSET)
    @State private var color: Color = .white
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    let maxZoom = IS_SMALL_WIDTH ? 1.7 : 2
    
    var body: some View {
        
        TextEditor(text: $viewModel.overlayText)
            .foregroundColor(color)
            .font(Font.system(size: 64, weight: .semibold, design: .rounded))
            .scaleEffect((finalAmount + currentAmount)/2)
            .position(location)
            .gesture(
                MagnificationGesture()
                    .onChanged { amount in
                        
                        if amount - 1 + finalAmount < maxZoom {
                            currentAmount = amount - 1
                            setTextMagnification()
                        }
                       
                    }
                    .onEnded { amount in
                        finalAmount += currentAmount
                        currentAmount = 0
                        viewModel.textMagnification = (finalAmount + currentAmount)
                    }
                    .simultaneously(with:  DragGesture()
                        .onChanged { value in
                            updateLocation(dragGesture: value)
                        }.updating($startLocation) { (value, startLocation, transaction) in
                            startLocation = startLocation ?? location // 2
                        })
            )
    }
    
    func setTextMagnification() {
        
    }
    
    func updateLocation(dragGesture value: DragGesture.Value) {
        
        var newLocation = startLocation ?? location
        newLocation.x += value.translation.width
        newLocation.y += value.translation.height
        
        //Text Magnification Scale
        let scale = finalAmount + currentAmount
        
        //initial width of text
        let offsetX = 89 * scale
        
        //initial height of text
        let offsetY: CGFloat = 60
      
        //Keep text within horizontal bounds
        self.location.x = min(SCREEN_WIDTH - offsetX, max(offsetX, newLocation.x))
        
        //Values that work based on testing
        let dif = scale > 1 ? scale/12: -scale/12
        
        //Keep text within vertical bounds
        self.location.y = min(MESSAGE_HEIGHT + TOP_PADDING_OFFSET - (offsetY*scale)/4, max(offsetY * (1 + dif) + 4, newLocation.y))
        viewModel.textLocationOffSet.width = 1 - self.location.x/(SCREEN_WIDTH/2)
        
        let height = MESSAGE_HEIGHT/2 + TOP_PADDING_OFFSET
        viewModel.textLocationOffSet.height = 1 - self.location.y/height
    }
}

struct TextOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TextOverlayView()
    }
}
