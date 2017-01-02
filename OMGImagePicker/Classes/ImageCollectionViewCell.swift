//
//  ImageCollectionViewCell.swift
//  ImagePickController
//
//  Created by 林涛 on 2016/12/9.
//  Copyright © 2016年 林涛. All rights reserved.
//

import UIKit
import Photos

class ImageCollectionViewCell: UICollectionViewCell {
    
    let checkBoxImageView = UIImageView()
    fileprivate let imageView = UIImageView()
    fileprivate let disableView = UIButton(type: UIButtonType.custom)
    
    var representedAssetIdentifier: String = ""
        var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bundle = Bundle(for: ImageCollectionViewCell.self)
        let url = bundle.url(forResource: "OMGImagePicker", withExtension: "bundle")
        checkBoxImageView.image = UIImage(named: "checkbox_normal", in: Bundle(url: url!), compatibleWith: nil)
        checkBoxImageView.highlightedImage = UIImage(named: "checkbox_selected", in: Bundle(url: url!), compatibleWith: nil)
        contentView.addSubview(imageView)
        contentView.addSubview(checkBoxImageView)
        contentView.addSubview(disableView)
        imageView.contentMode = .scaleToFill
        checkBoxImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        disableView.translatesAutoresizingMaskIntoConstraints = false
        disableView.backgroundColor = UIColor.white
        disableView.alpha = 0.5
        disableView.isHidden = true
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[disableView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["disableView":disableView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[disableView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["disableView":disableView]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[checkBoxImageView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["checkBoxImageView":checkBoxImageView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[checkBoxImageView]-5-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["checkBoxImageView":checkBoxImageView]))
        
        clipsToBounds = false
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(disable d:Bool)  {
        disableView.isHidden = !d
    }
   
    func config(with asset:PHAsset)  {
        PHCachingImageManager.default().requestImage(for: asset, targetSize: imageView.frame.size, contentMode: .aspectFill, options: nil){[unowned self] (result,_) in
            self.imageView.image = result
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        setCell(disable: false)
        checkBoxImageView.isHighlighted = false
        isSelected = false
    }
}
