//
//  PhotosCollectioView.swift
//  Saylo
//
//  Created by Student on 2021-10-15.
//

import UIKit
import Photos
import SwiftUI

protocol PhotosCollectioViewDelegate: AnyObject {
    func setHeightOffset(offset: CGFloat)
    func resetHeight()
    func hidePhotoPicker()
    func showAlert()
}

class PhotosCollectionView: UIView {
    
    weak var delegate: PhotosCollectioViewDelegate?
    
    private let AssetCollectionViewCellReuseIdentifier = "AssetCell"
    
    private var assetsFetchResults: PHFetchResult<PHAsset>?
    private var selectedAssets: [PHAsset] = [] {
        didSet {
            ConversationViewModel.shared.hasSelectedAssets = !selectedAssets.isEmpty
        }
    }
    
    private let numOffscreenAssetsToCache = 60
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var cachedIndexes: [IndexPath] = []
    private var lastCacheFrameCenter: CGFloat = 0
    private var cacheQueue = DispatchQueue(label: "cache_queue")
    private let width = (UIScreen.main.bounds.width - 3) / 4
    private var initialCenter:CGPoint!
    private var collectionView: UICollectionView!
    
    let sendButton: UIButton = {
        let button = UIButton()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular, scale: .medium)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: largeConfig), for: .normal)
        button.tintColor = .mainBlue
        button.backgroundColor = .systemWhite
        let width: CGFloat = 64
        button.setDimensions(height: width, width: width)
        button.layer.cornerRadius = width / 2
        button.isHidden = false
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    var selectedIndexes = [Int]()
    
    let requestOptions: PHImageRequestOptions = {
        let o = PHImageRequestOptions()
        o.isNetworkAccessAllowed = true
        o.resizeMode = .fast
        o.deliveryMode = .highQualityFormat
        return o
    }()
    
    private let dragView: UIView = {
        let view = UIView()
        view.setDimensions(height: 20, width: UIScreen.main.bounds.width)
        view.backgroundColor = .systemGray6
        
        let lineView = UIView()
        lineView.backgroundColor = .systemGray4
        lineView.setDimensions(height: 5, width: 40)
        lineView.layer.cornerRadius = 2.5
        
        view.addSubview(lineView)
        lineView.centerX(inView: view)
        lineView.centerY(inView: view)
        
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = .systemWhite
        collectionView.allowsMultipleSelection = true
        addSubview(collectionView)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20)
        collectionView.setDimensions(height: ConversationViewModel.shared.photoBaseHeight, width: SCREEN_WIDTH)
        
        resetCache()
        updateSelectedItems()
        fetchCollections()
        
        addSubview(sendButton)
        sendButton.anchor(bottom: bottomAnchor, right: rightAnchor, paddingBottom: 12, paddingRight: 12)
        sendButton.addTarget(self, action: #selector(sendImages), for: .touchUpInside)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        pan.delegate = self
        self.collectionView.addGestureRecognizer(pan)
        
        addSubview(dragView)
        dragView.anchor(top: topAnchor)
        dragView.centerX(inView: self)
        
        let dragPan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        dragPan.delegate = self
        self.dragView.addGestureRecognizer(dragPan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIsSendEnabled() {
        let viewModel = ConversationGridViewModel.shared
        
        if viewModel.isSelectingChats {
            if viewModel.selectedChats.count > 0 && ConversationViewModel.shared.hasSelectedAssets {
                sendButton.isEnabled = true
                sendButton.alpha = 1
            } else {
                sendButton.isEnabled = false
                sendButton.alpha = 0.5
            }
            
        } else {
            sendButton.isEnabled = selectedIndexes.isEmpty ? false : true
            sendButton.alpha = selectedIndexes.isEmpty ? 0.5 : 1
        }
        
    }
    
    //MARK: - Selectors
    
    @objc func sendImages() {
        for asset in selectedAssets {
            
            if asset.mediaType == .image {
                imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, metadata) in
                    let type: MessageType = asset.mediaType == .image ? .Photo : .Video
                    withAnimation(.easeInOut(duration: 0.2)) {
                        ConversationViewModel.shared.sendMessage(image: image, type: type)
                        ConversationGridViewModel.shared.stopSelectingChats()
                    }
                    
                }
            } else {
                imageManager.requestAVAsset(forVideo: asset, options: nil) { asset, mix, _  in
                    guard let asset = asset as? AVURLAsset else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        ConversationViewModel.shared.sendMessage(url: asset.url, type: .Video)
                        ConversationGridViewModel.shared.stopSelectingChats()
                    }
                    
                    
                }
            }
        }
        
        delegate?.hidePhotoPicker()
    }
    
    //MARK: - Helpers
    
    func currentAssetAtIndex(_ index:NSInteger) -> PHAsset {
        if let fetchResult = assetsFetchResults {
            return fetchResult[index]
        } else {
            return selectedAssets[index]
        }
    }
    
    func updateSelectedItems() {
        if let fetchResult = assetsFetchResults {
            for asset in selectedAssets {
                let index = fetchResult.index(of: asset)
                if index != NSNotFound {
                    let indexPath = IndexPath(item: index, section: 0)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        } else {
            for i in 0..<selectedAssets.count {
                let indexPath = IndexPath(item: i, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    func requestAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.fetchCollections()
                default:
                    print("NO ACCESS")
              
                }
            }
        }
    }
    
    func fetchCollections() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchedAssets = PHAsset.fetchAssets(with: options)
        assetsFetchResults = fetchedAssets
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate

extension PhotosCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let asset = currentAssetAtIndex(indexPath.item)
        if asset.mediaType == .video && asset.duration > 60 {
            delegate?.showAlert()
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = currentAssetAtIndex(indexPath.item)
        
        
        
        selectedAssets.append(asset)
        
        if let view = collectionView.cellForItem(at: indexPath) as? AssetCell{
            view.setSelectedNumber(selectedAssets.count)
            selectedIndexes.append(indexPath.row)
        }
        
        setIsSendEnabled()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let assetToDelete = currentAssetAtIndex(indexPath.item)
        selectedAssets = selectedAssets.filter({ (asset) -> Bool in
            return asset != assetToDelete
        })
        if assetsFetchResults == nil {
            collectionView.deleteItems(at: [indexPath])
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? AssetCell{
            if let selectedNumber = cell.getSelectedNumber() {
                selectedIndexes.forEach { (index) in
                    if let cell = collectionView.cellForItem(at: IndexPath(row: index, section:0)) as? AssetCell {
                        if let num = cell.getSelectedNumber(), num > selectedNumber {
                            cell.setSelectedNumber(num - 1)
                        }
                    }
                }
                
                selectedIndexes.removeAll(where: {$0 == indexPath.row})
                cell.setSelectedNumber(nil)
            }
        }
        
        setIsSendEnabled()
    }
}

// MARK: - UICollectionViewDataSource

extension PhotosCollectionView: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        
        if let fetchResult = assetsFetchResults {
            return fetchResult.count
        } else {
            return selectedAssets.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCellReuseIdentifier, for: indexPath) as! AssetCell
        cell.reuseCount = cell.reuseCount + 1
        let reuseCount = cell.reuseCount
        let asset = currentAssetAtIndex(indexPath.item)
        
        if let index = selectedIndexes.firstIndex(where: {$0 == indexPath.row}) {
            cell.setSelectedNumber(index + 1)
        }
        
        if asset.mediaType == .video {
            cell.setVideoLengthString(asset.duration.minuteSecond)
        }
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: width*2, height: width*2), contentMode: .aspectFill, options: requestOptions) { (image, metadata) in
            
            if reuseCount == cell.reuseCount {
                cell.setImage(image)
            }
        }
        
        return cell
    }
}


// MARK: - Caching

extension PhotosCollectionView {
    
    func updateCache() {
        let currentFrameCenter = bounds.minY
        let height = bounds.height
        let visibleIndexes = collectionView.indexPathsForVisibleItems.sorted { (a, b) -> Bool in
            return a.item < b.item
        }
        guard abs(currentFrameCenter - lastCacheFrameCenter) >= height/3.0,
              visibleIndexes.count > 0 else {
                  return
              }
        lastCacheFrameCenter = currentFrameCenter
        
        let totalItemCount = assetsFetchResults?.count ?? selectedAssets.count
        let firstItemToCache = max(visibleIndexes[0].item - numOffscreenAssetsToCache / 2, 0)
        let lastItemToCache = min(visibleIndexes[visibleIndexes.count - 1].item + numOffscreenAssetsToCache / 2, totalItemCount - 1)
        
        var indexesToStartCaching: [IndexPath] = []
        for i in firstItemToCache..<lastItemToCache {
            let indexPath = IndexPath(item: i, section: 0)
            if !cachedIndexes.contains(indexPath) {
                indexesToStartCaching.append(indexPath)
            }
        }
        
        cachedIndexes += indexesToStartCaching
        imageManager.startCachingImages(for: assetsAtIndexPaths(indexesToStartCaching), targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions)
        
        var indexesToStopCaching: [IndexPath] = []
        cachedIndexes = cachedIndexes.filter({ (indexPath) -> Bool in
            if indexPath.item < firstItemToCache || indexPath.item > lastItemToCache {
                indexesToStopCaching.append(indexPath)
                return false
            }
            return true
        })
        imageManager.stopCachingImages(for: assetsAtIndexPaths(indexesToStopCaching), targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions)
    }
    
    func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
        return indexPaths.map { (indexPath) -> PHAsset in
            return self.currentAssetAtIndex(indexPath.item)
        }
    }
    
    func resetCache() {
        imageManager.stopCachingImagesForAllAssets()
        cachedIndexes = []
        lastCacheFrameCenter = 0
    }
}

// MARK: - UIScrollViewDelegate

extension PhotosCollectionView {
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let velocity = sender.velocity(in: self)
        
        guard collectionView.contentOffset.y == 0 || velocity.y < 0 || sender.view == dragView else {return}
        
        
        switch sender.state {
        case .began, .changed:
            if translation.y >= 0 {
                delegate?.setHeightOffset(offset: translation.y)
            }
        case .ended:
            if translation.y > self.frame.height / 2.5 {
                delegate?.hidePhotoPicker()
                ConversationGridViewModel.shared.stopSelectingChats()
            } else  {
                delegate?.resetHeight()
            }
        default:
            break
        }
    }
    
    
    //TODO
    //1. show video leng if it's a vide0
    //2. add drag down bar
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
        cacheQueue.sync {
            self.updateCache()
        }
    }
    
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotosCollectionView: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange)  {
        
    }
}

extension PhotosCollectionView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
