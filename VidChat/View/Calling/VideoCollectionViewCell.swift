//
//  VideoCollectionViewCell.swift
//  VidChat
//
//  Created by Student on 2021-10-20.
//

import Foundation
import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
     var videoView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        videoView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        videoView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        videoView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
