//
//  AssetCell.swift
//  VidChat
//
//  Created by Student on 2021-10-15.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    private var imageView = UIImageView()
    private var numberLabel = UILabel()
    private var transparentOverlay = UIView()
    private var selectedNumber: Int?
    
    var reuseCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.frame = contentView.bounds
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(transparentOverlay)
        transparentOverlay.frame = contentView.bounds
        transparentOverlay.isHidden = true
        transparentOverlay.addSubview(numberLabel)
        transparentOverlay.backgroundColor = UIColor(white: 1, alpha: 0.6)

        numberLabel.contentMode = .scaleAspectFill
        numberLabel.backgroundColor = .systemBlue
        numberLabel.layer.cornerRadius = 10
        numberLabel.clipsToBounds = true
        numberLabel.tintColor = .white
        numberLabel.textAlignment = .center
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.textColor = .white
        
        let width: CGFloat = 28
        numberLabel.heightAnchor.constraint(equalToConstant: width).isActive = true
        numberLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        numberLabel.layer.cornerRadius = width/2
        numberLabel.centerYAnchor.constraint(equalTo: transparentOverlay.centerYAnchor).isActive = true
        numberLabel.centerXAnchor.constraint(equalTo: transparentOverlay.centerXAnchor).isActive = true
        
        if let number = selectedNumber {
            self.numberLabel.text = String(number)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        transparentOverlay.isHidden = !isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
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
