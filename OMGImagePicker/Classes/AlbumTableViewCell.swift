//
//  AlbumTableViewCell.swift
//  ImagePickController
//
//  Created by 林涛 on 2016/12/9.
//  Copyright © 2016年 林涛. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewCell: UITableViewCell {

    let photoCount: UILabel = UILabel()
    let thumbnailImage = UIImageView()
    let titleLabel = UILabel()
    
    var representedAssetIdentifier: String!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(photoCount)
        contentView.addSubview(thumbnailImage)
        contentView.addSubview(titleLabel)
        photoCount.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
      
        contentView.addConstraint(NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 8))
        contentView.addConstraint(NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 80))
         contentView.addConstraint(NSLayoutConstraint(item: thumbnailImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: thumbnailImage, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0))
        
         contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: thumbnailImage, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 13))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16))
        
        contentView.addConstraint(NSLayoutConstraint(item: photoCount, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: photoCount, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 2))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse()  {
        super.prepareForReuse()
        thumbnailImage.image = nil
    }
}
