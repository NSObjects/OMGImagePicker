//
//  ViewController.swift
//  OMGImagePicker
//
//  Created by NSObjects on 12/14/2016.
//  Copyright (c) 2016 NSObjects. All rights reserved.
//

import UIKit
import OMGImagePicker
import Photos

class ViewController: UIViewController {
    
    fileprivate let imageManager = PHCachingImageManager()
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var thumbnailSize: CGSize!
    var fetchResult:PHFetchResult<PHAsset>? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let scale = UIScreen.main.scale
        let cellSize = flowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.itemSize = CGSize(width: collectionView.frame.size.width - 30, height: collectionView.frame.size.height - 100)
    }
    
    @IBAction func showImagePickerView(_ sender: Any) {
        let pickViewController = OMGImagePickerViewController()
        pickViewController.delegate = self
        pickViewController.rightButtonTitle = "Done"
        pickViewController.maxNumberOfSelections = 5
        let navigationController = UINavigationController(rootViewController: pickViewController)
        present(navigationController, animated: true, completion: nil)
    }
}

 extension ViewController:OMGImagePickerViewControllerDelegate {
    func imagePickerViewControllerDidCancel(vc: OMGImagePickerViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerViewController(vc: OMGImagePickerViewController, didFinishPickingWith assets: PHFetchResult<PHAsset>) {
        self.fetchResult = assets
        vc.dismiss(animated: true, completion: nil)
    }
 }
 
 extension ViewController:UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as? CollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        
        let asset = fetchResult![indexPath.row]
       
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let requestOption = PHImageRequestOptions()
        // If image form icloud set isNetworkAccessAllowed=true
        //"Creating an image format with an unknown type is an error"
        requestOption.isNetworkAccessAllowed = true
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: requestOption, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
 }
 
