//
//  ImageDetailView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2021-12-21.
//

import SwiftUI
import Kingfisher

struct ImageDetailView: View {
    
    @State var showImageOptions = true
    @State var backGroundColor: Color = .systemWhite
    @State var dragOffset: CGSize = .zero
    @State var lastScaleValue: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    
    var body: some View {
        
        ZStack(alignment: .bottomLeading) {
            
            ZoomableScrollView {

                if let url = ConversationViewModel.shared.selectedUrl {
                    
                    KFImage(URL(string: url))
                        .resizable()
                        .scaledToFit()
                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                        .background(backGroundColor)
                        .clipped()
                        .scaleEffect(scale)
                    
                } else if let image = ConversationViewModel.shared.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
                        .background(backGroundColor)
                        .clipped()
                    
                }
            }
        }
        .onTapGesture {
            
            withAnimation {
                showImageOptions.toggle()
            }
            
            backGroundColor = backGroundColor == .systemWhite ? .systemBlack : .systemWhite
        }
        .gesture(
            
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { gesture in
                    dragOffset.height = max(0, gesture.translation.height)
                }
                .onEnded { gesture in
                    
                    withAnimation(.linear(duration: 0.2)) {
                        
                        if dragOffset.height > SCREEN_HEIGHT / 4 {
                            ConversationViewModel.shared.showImageDetailView = false
                        } else {
                            dragOffset.height = 0
                        }
                    }
                }
        )
        .background(backGroundColor)
        .overlay(ImageOptionsView(showImageOptions: $showImageOptions, dragOffset: $dragOffset))
        .offset(dragOffset)
    }
}

struct ImageOptionsView: View {
    
    @State private var isSharePresented: Bool = false
    
    @Binding var showImageOptions: Bool
    @Binding var dragOffset: CGSize
    
    var imageView = UIImageView()
    
    
    var body: some View {
        
        VStack {
            
            if showImageOptions {
                
                ZStack {
                    
                    Rectangle()
                        .frame(width: SCREEN_WIDTH, height: TOP_PADDING + 44)
                        .foregroundColor(.systemWhite)
                        .opacity(1.0 - (dragOffset.height/100))
                    
                    HStack {
                        
                        Button {
                            withAnimation(.linear(duration: 0.2)) {
                                ConversationViewModel.shared.showImageDetailView = false
                                ConversationViewModel.shared.selectedUrl = nil
                                ConversationViewModel.shared.selectedImage = nil
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(.systemBlue))
                                .frame(width: 24, height: 24)
                                .opacity(1.0 - (dragOffset.height/100))
                        }
                        
                        
                        Spacer()
                        
                        Button {
                            isSharePresented = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(.systemBlue))
                                .frame(width: 24, height: 24)
                                .opacity(1.0 - (dragOffset.height/100))
                        }.sheet(isPresented: $isSharePresented, onDismiss: {
                            
                        }, content: {
                            if let image = imageView.image {
                                ActivityViewController(activityItems: [image as UIImage])
                            }
                        })
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, TOP_PADDING + 4)
                    .padding(.bottom, 4)
                    
                }.transition(.move(edge: .top))
                
            }
            
            Spacer()
            
        }.onAppear {
            if let image = ConversationViewModel.shared.selectedImage {
                imageView.image = image
            } else if let url = ConversationViewModel.shared.selectedUrl {
                imageView.kf.setImage(with: URL(string: url))
            }
        }
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    static func dismantleUIView(_ uiView: UIScrollView, coordinator: Coordinator) {
        uiView.delegate = nil
        coordinator.hostingController.view = nil
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        print("MAKING")
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // create a UIHostingController to hold our SwiftUI content
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = CGRect(x: scrollView.bounds.minX, y: scrollView.bounds.minY, width: scrollView.bounds.width, height: scrollView.bounds.height)
        
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        //        var parent: ZoomableScrollView
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
            //            self.parent = zoomView
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}
