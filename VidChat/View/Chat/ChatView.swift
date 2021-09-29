
//
//  ChatView.swift
//  VidChat
//
//  Created by Student on 2021-09-26.
//

import SwiftUI
import Kingfisher

enum ConversationStatus {
    case sent, received, receivedOpened, sentOpened, none
}

struct TestUser {
    let image: String
    let firstname: String
    let lastname: String
    let id = UUID()
    var conversationStatus: ConversationStatus = .none
}

struct ChatView: View {
    let image1 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%202.54.09%20PM.png?alt=media&token=0a1b499c-a2d9-416f-ab99-3f965939ed66"
    let image2 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Screen%20Shot%202021-09-26%20at%203.23.09%20PM.png?alt=media&token=e1ff51b5-3534-439b-9334-d2f5bc1e37c1"
    let image3 = "https://firebasestorage.googleapis.com/v0/b/vidchat-12c32.appspot.com/o/Slice%20102.png?alt=media&token=8f470a6e-738b-4724-8fe9-ada2305d48ef"
    
    private let items = [GridItem(), GridItem()]
    private var users: [TestUser]
    @State private var showCamera = false
    //  @ObservedObject var viewModel: PostGridViewModel
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.darkText]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.darkText]
        appearance.backgroundColor = .white
        appearance.shadowImage = UIImage(named: "shadow")
        //appearance.shadowColor = .black
        //appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialLight)
        UINavigationBar.appearance().layer.masksToBounds = false
        UINavigationBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UINavigationBar.appearance().layer.shadowOpacity = 0.8
        UINavigationBar.appearance().layer.shadowOffset = CGSize(width: 0, height: 2.0)
        UINavigationBar.appearance().layer.shadowRadius = 2
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        self.users =  [TestUser(image: image1, firstname: "Sebastian", lastname: "Danson", conversationStatus: .received),
                       TestUser(image: image2, firstname: "Max", lastname: "Livingston", conversationStatus: .sent),
                       TestUser(image: image3, firstname: "Hayden", lastname: "Middlebrook"),
                       TestUser(image: image1, firstname: "Sebastian", lastname: "Danson"),
                       TestUser(image: image2, firstname: "Max", lastname: "Livingston", conversationStatus: .sentOpened),
                       TestUser(image: image3, firstname: "Hayden", lastname: "Middlebrook"),
                       TestUser(image: image1, firstname: "Sebastian", lastname: "Danson", conversationStatus: .receivedOpened),
                       TestUser(image: image2, firstname: "Max", lastname: "Livingston"),
                       TestUser(image: image3, firstname: "Hayden", lastname: "Middlebrook"),
                       TestUser(image: image1, firstname: "Sebastian", lastname: "Danson"),
                       TestUser(image: image2, firstname: "Max", lastname: "Livingston"),
                       TestUser(image: image3, firstname: "Hayden", lastname: "Middlebrook")]
        
    }
    
    
    var body: some View {
        if showCamera {
            CameraMainView(viewModel: CameraViewModel(), showCamera: $showCamera)
                .transition(.scale)
        } else {
            
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack {
                        LazyVGrid(columns: items, spacing: 24, content: {
                            ForEach(self.users, id: \.id) { user in
                                ChatCell(user: user)
                                    .flippedUpsideDown()
                                
                            }
                            
                        })
                        .padding(16)
                        
                    }.padding(.top, 40)
                }
                .flippedUpsideDown()
                .navigationBarTitle("Conversations", displayMode: .inline)
                .ignoresSafeArea()
                .overlay(
                    Button(action: {
                        withAnimation {
                            self.showCamera.toggle()
                        }
                    }, label: {
                        ShowCameraView()
                    })
                    .padding(.bottom, 26)
                    .padding(.trailing, 12)
                    , alignment: .bottomTrailing)
                .zIndex(1)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(spacing: 12) {
                          //  Button(action: {}, label: {
                                KFImage(URL(string: image1))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            //})
                            
//                            Button(action: {}, label: {
//                                Image(systemName: "magnifyingglass.circle.fill")
//                                    .resizable()
//                                    .frame(width: 32, height: 32)
//                                    .scaledToFill()
//                                    .background(
//                                        Circle()
//                                            .foregroundColor(Color.init(UIColor.systemGray.cgColor))
//                                            .frame(width: 30, height: 30)
//
//                                    )
//                                    .foregroundColor(Color.init(UIColor.systemGray5.cgColor))
//                            })
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VStack {
                            Circle()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.mainBlue)
                                .overlay(
                                    Image(systemName: "person.fill.badge.plus")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(.trailing, 2)
                                )
              
                        }
                    }
                }
            }
        }
    }
}

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
extension View{
    func flippedUpsideDown() -> some View{
        self.modifier(FlippedUpsideDown())
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

struct ShowCameraView: View {
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.mainBlue)
                .frame(width: 65, height: 65)
                .shadow(color: Color(.init(white: 0, alpha: 0.3)),
                        radius: 12, x: 0, y: 12)
            Image("video")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }
}
