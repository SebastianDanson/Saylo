//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-10-07.
//

import SwiftUI

struct ConversationView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    @ObservedObject var viewModel = ConversationViewModel.shared
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    @State private var dragOffset = CGSize.zero
    @State private var canScroll = true

    private let width = UIScreen.main.bounds.width
    private let cameraHeight = UIScreen.main.bounds.width * 1.25
    private let screenHeight = UIScreen.main.bounds.height
    private let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    let colors: [Color] = [.red, .green, .blue]
    let prevCOntentOffset: CGFloat = 0
    
    var body: some View {
        
        
        ZStack(alignment: .bottom) {
            
            //Feed
            
            TrackableScrollView(.vertical, showIndicators: false, contentOffset: $scrollViewContentOffset) {
                ScrollViewReader { reader in
                    
                    
                    //Text("\(scrollViewContentOffset)")
                    
                    
                    Rectangle().frame(height: 100).foregroundColor(.white)
                    
                    
                    LazyVStack(spacing: 20) {
                        
                        
                        ForEach(Array(viewModel.messages.enumerated()), id: \.1.id) { i, element in
                            MessageCell(message: viewModel.messages[i])
                                .offset(x: 0, y: dragOffset.height)
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onChanged { gesture in
                                           // if canScroll {
                                                print("CHANGED")
                                                dragOffset.height = gesture.translation.height
                                          //  }
                                        }
                                        .onEnded { gesture in
                                            print(dragOffset, "DRAG OFFSET")
                                            if abs(dragOffset.height) > 100 {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                dragOffset = .zero
                                            }
                                            } else {
                                                withAnimation {
                                                    dragOffset = .zero
                                                }
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                print("YUPPP")
                                                canScroll = true
                                            }
                                            if canScroll {
                                              
                                            print(gesture.translation, "TRAN")
                                            if gesture.translation.height < 0 {
                                                if i + 1 < viewModel.messages.count {
                                                    withAnimation() {
                                                        reader.scrollTo(viewModel.messages[i + 1].id, anchor: .center)
                                                        canScroll = false
                                                    }
                                                }
                                            }
                                            
                                            if gesture.translation.height > 0 {
                                                if i - 1 >= 0 {
                                                    withAnimation() {
                                                        reader.scrollTo(viewModel.messages[i - 1].id, anchor: .center)
                                                        canScroll = false
                                                    }
                                                }
                                            }

                                            }
                                            }
                                ) .allowsHitTesting(canScroll)

                            //                                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded({ value in
                            //                                    if value.translation.height < 0 {
                            //                                        if i + 1 < viewModel.messages.count {
                            //                                            withAnimation {
                            //                                                reader.scrollTo(viewModel.messages[i + 1].id, anchor: .center)
                            //                                            }
                            //                                        }
                            //                                    }
                            //
                            //                                    if value.translation.height > 0 {
                            //                                        if i - 1 >= 0 {
                            //                                            withAnimation {
                            //                                                reader.scrollTo(viewModel.messages[i - 1].id, anchor: .center)
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                })).delayTouches()
                            
                            
                            
                            // .onTapGesture{}.onLongPressGesture(minimumDuration: 0) { // Setting the minimumDuration to ~0.2 reduces the delay
                            
                            //                                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            //                                            .onChanged({ value in
                            //                                    scrollViewContentOffset += value.translation.height
                            //
                            //                                })
                            //                                .simultaneousGesture(LongPressGesture(minimumDuration: 1)
                            //                                            .onEnded { _ in
                            //                                    print("ENDED")
                            //                                })
                            //                                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            //                                            .onChanged({ value in
                            //                                    scrollViewContentOffset += value.translation.height
                            //
                            //                                })
                            //                                            .onEnded({ value in
                            //                                    if value.translation.height < 0 {
                            //                                        if i + 1 < viewModel.messages.count {
                            //                                            withAnimation {
                            //                                                reader.scrollTo(viewModel.messages[i + 1].id, anchor: .center)
                            //                                            }
                            //                                        }
                            //                                    }
                            //
                            //                                    if value.translation.height > 0 {
                            //                                        if i - 1 >= 0 {
                            //                                            withAnimation {
                            //                                                reader.scrollTo(viewModel.messages[i - 1].id, anchor: .center)
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                }))
                            //  .delayTouches()
                            
                            
                        }
                        
                        Rectangle().frame(height: 100).foregroundColor(.white)
                        
                        
                        
                    }.flippedUpsideDown()
                    //                        .onChange(of: scrollViewContentOffset) { V in
                    //
                    //                            if viewModel.messages.count > 3 {
                    //                                value.scrollTo(viewModel.messages[3].id, anchor: .center)
                    //                            }
                    //                        }
                }
            }.flippedUpsideDown()
            
            
            
            // ScrollView {
            
            //                ScrollViewReader { value in
            //
            //                   Rectangle().frame(height: 100).foregroundColor(.white)
            //
            //
            //
            //
            //                    LazyVStack(spacing: 20) {
            //
            //
            //                        ForEach(viewModel.messages) { message in
            //                            MessageCell(message: message)
            //                        }
            //
            //                          Rectangle().frame(height: 100).foregroundColor(.white)
            //
            //
            //
            //                    }.flippedUpsideDown()
            //                }
            
            //  }.flippedUpsideDown()
            
            
            //Camera
            if CameraViewModel.shared.showCamera {
                CameraViewModel.shared.cameraView
                    .transition(.move(edge: .bottom))
                    .frame(height: cameraHeight + (screenHeight - cameraHeight)/2)
            }
            
        }
        .overlay(OptionsView().transition(.opacity), alignment: .bottom)
        .edgesIgnoringSafeArea(.all)
    }
    
}


/* The 5 buttons at the bottom of the chat */

struct OptionsView: View {
    
    @ObservedObject var cameraViewModel = CameraViewModel.shared
    let bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
    
    var body: some View {
        HStack(spacing: 4) {
            if cameraViewModel.url == nil {
                if !cameraViewModel.isRecording {
                    
                    //Camera button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "camera.fill"), imageDimension: 30, circleDimension: 50)
                    })
                    
                    //Photos button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "photo.on.rectangle.angled"), imageDimension: 31, circleDimension: 50)
                    })
                    
                }
                
                //Video record circle
                Button(action: {
                    withAnimation {
                        cameraViewModel.handleTap()
                    }
                }, label: {
                    CameraCircle().padding(.horizontal, 10)
                })
                
                if !cameraViewModel.isRecording {
                    
                    //Mic button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "mic.fill"), imageDimension: 27, circleDimension: 50)
                    })
                    
                    //Aa button
                    Button(action: {}, label: {
                        ActionView(image: Image(systemName: "textformat.alt"), imageDimension: 32, circleDimension: 50)
                    })
                    
                }
            }
        }
        .frame(height: 70)
        .clipShape(Capsule())
        .padding(.bottom, bottomPadding + (cameraViewModel.isRecording ? 20 : 0))
    }
}

/* The button that records video */
struct CameraCircle: View {
    @StateObject var viewModel = CameraViewModel.shared
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
            .stroke(Color.mainBlue, style: StrokeStyle(lineWidth: 6,
                                                       lineCap: .round,
                                                       lineJoin: .round))
            .animation(.linear(duration: viewModel.progress == 0 ? 0 : 20), value: viewModel.progress)
            .frame(width: 60, height: 60)
            .rotationEffect(Angle(degrees: 270))
            .overlay(
                Circle()
                    .strokeBorder(viewModel.isRecording ? Color.clear : Color(.systemGray), lineWidth: viewModel.isRecording ? 3 : 6)
                    .background(
                        VStack {
                            RoundedRectangle(cornerRadius: viewModel.isRecording ? 6:28)
                                .frame(width: viewModel.isRecording ? 28:0,
                                       height: viewModel.isRecording ? 28:0)
                                .foregroundColor(.red)
                                .transition(.scale)
                        }
                    )
                    .frame(width: 60, height: 60)
            )
    }
}

/* The buttons along the bottom of the chat (camera, photos, audio, text buttons) */

struct ActionView: View {
    let image: Image
    let imageDimension: CGFloat
    let circleDimension: CGFloat
    let color: Color
    
    init(image: Image, imageDimension: CGFloat = 32, circleDimension: CGFloat = 60, color: Color = Color(.systemGray)) {
        self.image = image
        self.imageDimension = imageDimension
        self.circleDimension = circleDimension
        self.color = color
    }
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .frame(width: imageDimension, height: imageDimension)
            .padding(20)
    }
}

struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content
    
    init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                        // Send value to the parent
                    }
                    VStack {
                        self.content
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
            }
            // Get the value then assign to offset binding
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension View {
    func delayTouches() -> some View {
        Button(action: {}) {
            gesture(TapGesture())
        }
        .buttonStyle(NoButtonStyle())
    }
}
