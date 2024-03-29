//
//  LastPhotoView.swift
//  Saylo
//
//  Created by Sebastian Danson on 2022-03-26.
//

import SwiftUI
import PhotosUI

struct LastPhotoView: View {
    
    @State var selectedImage: UIImage?
    let dimension: CGFloat = IS_SMALL_WIDTH ? 28 : 30
    
    var body: some View {
        
        ZStack {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: dimension, height: dimension)
                    .cornerRadius(8)
                    .padding(1) // Width of the border
                    .background(Color.white) // Color of the border
                    .cornerRadius(8)
            } else {
                
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: dimension - 3, height: dimension - 3)
                    .shadow(color: Color(white: 0, opacity: 0.4), radius: 4, x: 0, y: 4)
                
            }
        }.onAppear {
            if PhotosViewModel.shared.getHasAccessToPhotos() {
//                DispatchQueue.global().async {
                    self.queryLastPhoto(resizeTo: nil) { image in
                        self.selectedImage = image
                    }
//                }
            }
        }
        .frame(width: dimension, height: dimension)
    }
    
    func queryLastPhoto(resizeTo size: CGSize?, queryCallback: @escaping ((UIImage?) -> Void)) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        if let asset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            
            let targetSize = size == nil ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight) : size!
            
            manager.requestImage(for: asset,
                                    targetSize: targetSize,
                                    contentMode: .aspectFit,
                                    options: requestOptions,
                                    resultHandler: { image, info in
                queryCallback(image)
            })
        }
    }
}

struct LastPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        LastPhotoView()
    }
}
