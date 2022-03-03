//
//  PlaybackSlider.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-02.
//

//import UIKit
//import AVKit
import SwiftUI

struct PlaybackSlider: View {
    
    @State var sliderValue: Double = 0
    @State var time = 5
    @State var timer: Timer?
    
    @State var prevValue = 0.0
    let stepAmount = 0.002
    var body: some View {

        Slider(value: $sliderValue, in: 0...1, step: 0.001)
            .accentColor(Color.white)
            .onChange(of: sliderValue) { newValue in
                
                if abs(newValue - prevValue) > 2 * stepAmount {
                    print("YESSIR")
                }
                
                if newValue >= 1 {
                    ConversationViewModel.shared.showNextMessage()
                    DispatchQueue.main.async {
                        prevValue = 0
                        sliderValue = 0
                    }
                }
                
                prevValue = newValue
            }
            .onAppear {
                start()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    func start() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            timer in
            
            withAnimation {
                self.sliderValue += stepAmount
            }
        
        }
    }
}
//struct PlaybackSlider: UIViewRepresentable {
//
//    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlaybackSlider>) {
//    }
//
//    func makeUIView(context: Context) -> UIView {
//        let slider = MessageSlider()
//        return slider
//    }
//}
//
//class MessageSlider: UIView {
//
//    private let playbackSlider = UISlider()
//    private var timeObserverToken: Any?
//
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(playbackSlider)
//        playbackSlider.frame = self.frame
//        playbackSlider.setDimensions(height: 30, width: ConversationViewModel.shared.showCamera ? SCREEN_WIDTH - 64 : SCREEN_WIDTH - 100)
//        playbackSlider.minimumValue = 0
//        playbackSlider.maximumValue = 1
//
//        playbackSlider.isContinuous = true
//        playbackSlider.tintColor = UIColor.white
//
//        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
//        self.addSubview(playbackSlider)
//        playbackSlider.centerX(inView: self)
//        playbackSlider.anchor(bottom: bottomAnchor, paddingBottom: 8)
//        addPeriodicTimeObserver()
//
//    }
//
//    @objc
//    func playbackSliderValueChanged(_ playbackSlider:UISlider)
//    {
//        guard let player = ConversationViewModel.shared.currentPlayer else {return}
//        playbackSlider.thumbTintColor = .white
//        let seconds : Double = Double(playbackSlider.value)
//        let duration = player.currentItem?.asset.duration ?? .zero
//
//        let targetTime:CMTime = CMTime(seconds: duration.seconds * seconds, preferredTimescale: 1)
//        print(targetTime)
//        player.seek(to: targetTime)
//
//        if player.rate == 0
//        {
//           player.playWithRate()
//        }
//    }
//
//    func addPeriodicTimeObserver() {
//
//
//        // Notify every half second
//        let timeScale = CMTimeScale(NSEC_PER_SEC)
//        let time = CMTime(seconds: 0.05, preferredTimescale: timeScale)
//        guard let player = ConversationViewModel.shared.currentPlayer else {return}
//
//        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
//                                                                        queue: .main) {
//            [weak self] time in
//
//            guard let player = ConversationViewModel.shared.currentPlayer else {return}
//
//            if self?.playbackSlider.state ?? .normal == .normal {
//                let duration : CMTime = player.currentItem?.asset.duration ?? .zero
//
//                self?.playbackSlider.setValue(Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration)), animated: true)
//                self?.playbackSlider.thumbTintColor = .clear
//            }
//        }
//    }
//}
