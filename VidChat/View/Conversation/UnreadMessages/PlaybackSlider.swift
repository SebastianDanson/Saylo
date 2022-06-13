//
//  PlaybackSlider.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-02.
//

//import UIKit
import AVKit
import SwiftUI

struct PlaybackSlider: View {
    
    @Binding var sliderValue: Double
    @Binding var isPlaying: Bool
    @Binding var showPlaybackControls: Bool
    @Binding var showReactions: Bool
    @State var showSlider = false
    @State var timer: Timer?
    
    let viewModel = ConversationViewModel.shared
    
    var body: some View {
        
        SwiftUISlider(thumbColor: showPlaybackControls ? .white : .clear, minTrackColor: .white, maxTrackColor: .systemGray,
                      value: $sliderValue, showPlaybackControls: $showPlaybackControls, showSlider: $showSlider)
        //            .onChange(of: sliderValue) { newValue in
        //
        //                if newValue >= 1 {
        //                    ConversationViewModel.shared.showNextMessage()
        //                    DispatchQueue.main.async {
        //                        sliderValue = 0
        //                    }
        //                }
        //
        //            }
        .onAppear {
            start()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func handleSliderChanged() {
        let seconds = sliderValue
        let duration = viewModel.currentPlayer?.currentItem?.asset.duration ?? .zero
        
        let targetTime:CMTime = CMTime(seconds: duration.seconds * seconds, preferredTimescale: 1)
        viewModel.currentPlayer?.seek(to: targetTime)
    }
    
    func start() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            timer in
            
            if let curentPlayer = viewModel.currentPlayer, curentPlayer.isPlaying, curentPlayer.currentTime() != .zero {
                let value = curentPlayer.currentTime().seconds / (curentPlayer.currentItem?.duration.seconds ?? 0)
                withAnimation(.linear(duration: 0.01)) {
                    self.sliderValue = value
                }
            } else if isPlaying, viewModel.videoLength > 0 {
                
                withAnimation(.linear(duration: 0.01)) {
                    self.sliderValue += 0.01 / viewModel.videoLength
                }
                
                if sliderValue >= 1, !showReactions {
                    ConversationViewModel.shared.showNextMessage()
                }
            }
        }
    }
}

struct SwiftUISlider: UIViewRepresentable {
    
    final class Coordinator: NSObject {
        // The class property value is a binding: It’s a reference to the SwiftUISlider
        // value, which receives a reference to a @State variable value in ContentView.
        var value: Binding<Double>
        @Binding var showSlider: Bool
        
        // Create the binding when you initialize the Coordinator
        init(value: Binding<Double>, showSlider: Binding<Bool>) {
            self.value = value
            self._showSlider = showSlider
        }
        
        // Create a valueChanged(_:) action
        @objc func valueChanged(_ sender: UISlider, event: UIEvent) {
            
            
            if let touchEvent = event.allTouches?.first {
                switch touchEvent.phase {
                case .began:
                    ConversationViewModel.shared.pause()
                    showSlider = true
                    
                case .moved:
                    self.value.wrappedValue = Double(sender.value)
                case .ended:
                    ConversationViewModel.shared.play()
                    self.value.wrappedValue = Double(sender.value)
                    showSlider = false
                    
                    let seconds = sender.value
                    let duration = ConversationViewModel.shared.currentPlayer?.currentItem?.asset.duration ?? .zero
                    
                    let targetTime:CMTime = CMTime(seconds: duration.seconds * Double(seconds), preferredTimescale: 1)
                    ConversationViewModel.shared.currentPlayer?.seek(to: targetTime)
                default:
                    break
                }
            }
        }
    }
    
    var thumbColor: UIColor = .white
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    
    @Binding var value: Double
    @Binding var showPlaybackControls: Bool
    @Binding var showSlider: Bool
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.value = Float(value)
        slider.isContinuous = true
        
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:event:)),
            for: .valueChanged
        )
        
        
        return slider
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        // Coordinating data between UIView and SwiftUI view
        uiView.value = Float(self.value)
        uiView.thumbTintColor = showPlaybackControls || showSlider ? .white : .clear
    }
    
    
    func makeCoordinator() -> SwiftUISlider.Coordinator {
        Coordinator(value: $value, showSlider: $showSlider)
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

