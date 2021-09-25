//
//  UploadPostView.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-23.
//

import SwiftUI

struct UploadPostView: View {
    @State private var selectedImage: UIImage?
    @State var postImage: Image?
    @State var captionText = ""
    @State var imagePickerPresented = false
    @ObservedObject var viewModel = UploadPostViewModel()
    @Binding var tabIndex: Int
    
    var body: some View {
        VStack {
            if postImage == nil {
                Button(action: {imagePickerPresented.toggle()}, label: {
                    Image(systemName: "house")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipped()
                        .padding(.top, 56)
                        .foregroundColor(.black)
                }).sheet(isPresented: $imagePickerPresented, onDismiss: loadImage, content: {
                    ImagePicker(image: $selectedImage)
                })
            } else if let image = postImage {
                //if let image = postImage {
                    HStack(alignment: .top) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipped()
                        
                        TextArea(text: $captionText, placeholder: "Enter your caption...")
                            .frame(height: 200)
                    }
                
                Button(action: {
                    if let selectedImage = selectedImage {
                        viewModel.uploadPost(caption: captionText, image: selectedImage) { _ in
                            self.captionText = ""
                            self.postImage = nil
                            self.tabIndex = 0
                        }
                    }
                }, label: {
                    Text("Share")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 360, height: 50)
                        .background(Color.blue)
                        .cornerRadius(5)
                        .foregroundColor(.white)
                }).padding()
                //}
            }
            
            Spacer()
        }
    }
}

extension UploadPostView {
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        postImage = Image(uiImage: selectedImage)
    }
}

