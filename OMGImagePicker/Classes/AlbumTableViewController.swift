//
//  AlbumTableViewController.swift
//  ImagePickController
//
//  Created by 林涛 on 2016/12/9.
//  Copyright © 2016年 林涛. All rights reserved.
//

import UIKit
import Photos

protocol AlbumTableViewControllerDelegate:NSObjectProtocol {
    func albumViewController(vc:AlbumTableViewController, didSelect assetCollection:PHAssetCollection)
    func albumViewController(vc:AlbumTableViewController, didAllPhoto result:PHFetchResult<PHAsset>)
}

class AlbumTableViewController: UITableViewController {
   private enum Section: Int {
        case allPhotos = 0
        case smartAlbums
        static let count = 2
    }
    
    public weak var delegate:AlbumTableViewControllerDelegate?
    
    fileprivate var thumbnailSize: CGSize!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var allPhotos: PHFetchResult<PHAsset>?
    fileprivate var smartAlbums:[PHAssetCollection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: String(describing: AlbumTableViewCell.self))
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var smartAlbums = [PHAssetCollection]()
        albums.enumerateObjects({ (collection, index, stop) in
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            if result.count > 0 {
                smartAlbums.append(collection)
            }
        })
      self.smartAlbums = smartAlbums
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.superview?.layer.cornerRadius = 0
        view.superview?.backgroundColor = UIColor.white
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: 100 * scale, height: 100 * scale)
    }
  
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums?.count ?? 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int  {
        return Section.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumTableViewCell.self), for: indexPath) as! AlbumTableViewCell
            cell.titleLabel.text = NSLocalizedString("All Photos", comment: "")
            if let allPhotos = allPhotos {
                cell.photoCount.text = "\(allPhotos.count)"
                if let asset = allPhotos.firstObject {
                    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                        cell.thumbnailImage.image = image
                    })
                }
            }
         
            return cell
        case .smartAlbums:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumTableViewCell.self), for: indexPath) as! AlbumTableViewCell
            
            let collection = smartAlbums![indexPath.row]
            
            let option = PHFetchOptions()
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let photos = PHAsset.fetchAssets(in: collection, options: option)
            cell.photoCount.text = "\(photos.count)"
            if let asset = photos.firstObject {
                imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                     cell.thumbnailImage.image = image
                })
            }
            
            cell.titleLabel.text = collection.localizedTitle
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 101
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            delegate?.albumViewController(vc: self, didAllPhoto: allPhotos!)
        case .smartAlbums:
            delegate?.albumViewController(vc: self, didSelect: smartAlbums![indexPath.row])
        }
    }

}
