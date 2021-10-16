//
//  PhotosCollectioView.swift
//  VidChat
//
//  Created by Student on 2021-10-15.
//

import UIKit
import Photos

protocol SelectedAssetsDelegate {
    func updateSelectedAssets(_ assets: [PHAsset])
}

class PhotosCollectioView: UIView {
    
    private var selectedAssetsDelegate: SelectedAssetsDelegate?
    private let AssetCollectionViewCellReuseIdentifier = "AssetCell"
    
    private var assetsFetchResults: PHFetchResult<PHAsset>?
    private var selectedAssets: [PHAsset] = [] {
        didSet {
            sendView.isHidden = selectedAssets.count == 0
        }
    }
    
    private let numOffscreenAssetsToCache = 60
    private let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var cachedIndexes: [IndexPath] = []
    private var lastCacheFrameCenter: CGFloat = 0
    private var cacheQueue = DispatchQueue(label: "cache_queue")
    private let width = (UIScreen.main.bounds.width - 3) / 4
    
    private var collectionView: UICollectionView!
    
    private let sendView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "arrow.up.circle.fill"))
        iv.tintColor = .mainBlue
        iv.backgroundColor = .white
        let width: CGFloat = 60
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: width).isActive = true
        iv.widthAnchor.constraint(equalToConstant: width).isActive = true
        iv.layer.cornerRadius = width / 2
        iv.isHidden = true
        return iv
    }()
    
    private var selectedIndexes = [Int]()
    
    let requestOptions: PHImageRequestOptions = {
        let o = PHImageRequestOptions()
        o.isNetworkAccessAllowed = true
        o.resizeMode = .fast
        o.deliveryMode = .highQualityFormat
        return o
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.scrollDirection = .vertical
        
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AssetCell.self, forCellWithReuseIdentifier: AssetCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = .white
        collectionView.allowsMultipleSelection = true
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/4 * 3).isActive = true
        collectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        resetCache()
        updateSelectedItems()
        fetchCollections()
        
        addSubview(sendView)
        sendView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        sendView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        bringSubviewToFront(sendView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                    
                    //TODO add alert
                    // self.showNoAccessAlert()
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

extension PhotosCollectioView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = currentAssetAtIndex(indexPath.item)
        selectedAssets.append(asset)
        
        if let view = collectionView.cellForItem(at: indexPath) as? AssetCell{
            view.setSelectedNumber(selectedAssets.count)
            selectedIndexes.append(indexPath.row)
        }
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
    }
}

// MARK: - UICollectionViewDataSource

extension PhotosCollectioView: UICollectionViewDataSource {
    
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
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: width*2, height: width*2), contentMode: .aspectFill, options: requestOptions) { (image, metadata) in
            if reuseCount == cell.reuseCount {
                cell.setImage(image)
            }
        }
        
        return cell
    }
}


// MARK: - Caching

extension PhotosCollectioView {
    
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

extension PhotosCollectioView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        cacheQueue.sync {
            self.updateCache()
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotosCollectioView: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange)  {
        
    }
}