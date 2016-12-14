//
//  CollectionViewCell.swift
//  OMGImagePicker
//
//  Created by 林涛 on 2016/12/14.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var representedAssetIdentifier = ""
    var thumbnailImage:UIImage? {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
}
