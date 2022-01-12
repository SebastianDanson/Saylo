//
//  AssetCell.swift
//  VidChat
//
//  Created by Student on 2021-10-15.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    private var imageView = UIImageView()
    private var selectedNumber: Int?
    private lazy var numberLabel = UILabel()
    private lazy var transparentOverlay = UIView()
    
    private lazy var videoLengthLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        let height: CGFloat = 20
        label.setDimensions(height: height, width: 44)
        label.layer.cornerRadius = height/2
        label.textAlignment = .center
        label.textColor = .systemWhite
        label.backgroundColor = UIColor(white: 0, alpha: 0.4)
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    var reuseCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.frame = contentView.bounds
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        
        contentView.addSubview(videoLengthLabel)
        videoLengthLabel.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                                paddingBottom: 8, paddingRight: 8)
        
        contentView.addSubview(transparentOverlay)
        transparentOverlay.frame = contentView.bounds
        transparentOverlay.isHidden = true
        transparentOverlay.addSubview(numberLabel)
        transparentOverlay.backgroundColor = UIColor(white: 1, alpha: 0.6)

        numberLabel.contentMode = .scaleAspectFill
        numberLabel.backgroundColor = .systemBlue
        numberLabel.layer.cornerRadius = 10
        numberLabel.clipsToBounds = true
        numberLabel.tintColor = .systemWhite
        numberLabel.textAlignment = .center
        numberLabel.textColor = .systemWhite
        
        let width: CGFloat = 28
        numberLabel.setDimensions(height: width, width: width)
        numberLabel.layer.cornerRadius = width/2
        numberLabel.centerY(inView: transparentOverlay)
        numberLabel.centerX(inView: transparentOverlay)
        
        if let number = selectedNumber {
            self.numberLabel.text = String(number)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        transparentOverlay.isHidden = !isSelected
        videoLengthLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
    
    func setVideoLengthString(_ videoLengthString: String) {
        videoLengthLabel.isHidden = false
        videoLengthLabel.text = videoLengthString
    }
    
    func setSelectedNumber(_ number: Int?) {
        self.selectedNumber = number
        
        if let number = number {
            self.numberLabel.text = String(number)
        } 
    }
    
    func getSelectedNumber() -> Int? {
        return self.selectedNumber
    }
    
    override var isSelected: Bool {
        didSet {
            transparentOverlay.isHidden = !isSelected
        }
    }
    
    
}
