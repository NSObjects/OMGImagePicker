//
//  OMGImagePickerViewController.swift
//  Pods
//
//  Created by 林涛 on 2016/12/14.
//
//

import UIKit
import Photos

public extension UIViewController {
    public func present(omg_present viewController: UIViewController,
                        delegate: OMGImagePickerViewControllerDelegate,
                        setting: OMGImagePickerSetting? = nil) {
        let pickViewController = OMGImagePickerViewController()
        pickViewController.delegate = delegate
        let navigationController = UINavigationController(rootViewController: pickViewController)
        if let setting = setting {
            pickViewController.setting = setting
        }
        viewController.present(navigationController, animated: true, completion: nil)
    }
}

public protocol OMGImagePickerViewControllerDelegate:NSObjectProtocol {
    func imagePickerViewController(imagePickerViewController:OMGImagePickerViewController,didFinishPickingWith assets:PHFetchResult<PHAsset>)
    func imagePickerViewControllerDidCancel(imagePickerViewController:OMGImagePickerViewController)
    func userDeniedAuthPhotosView(imagePickerViewController:OMGImagePickerViewController)->UIView?
}

public class OMGImagePickerViewController: UIViewController {
    
    fileprivate weak var delegate:OMGImagePickerViewControllerDelegate?
    fileprivate var setting = OMGImagePickerSetting()
    fileprivate var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate var rightBarButton:UIBarButtonItem!
    fileprivate var collectionView:UICollectionView?
    fileprivate var flowLayout:UICollectionViewFlowLayout?
    fileprivate var thumbnailSize: CGSize!
    fileprivate var albumSelectButton:UIButton!
    fileprivate var selectAssetCollection:PHAssetCollection?
    
    fileprivate var fetchResult:PHFetchResult<PHAsset>! {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    fileprivate var selectionPhotoIdentifier = [String]() {
        didSet {
            rightBarButton.tintColor = selectionPhotoIdentifier.count > 0 ? UIColor.red : UIColor.gray
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewSetup()
        if let flowLayout = flowLayout {
            let scale = UIScreen.main.scale
            let cellSize = flowLayout.itemSize
            thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        }
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

// MARK: - UICollectionViewDataSource
extension OMGImagePickerViewController:UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        if indexPath.row == 0 {
            if selectionPhotoIdentifier.count >= setting.maxNumberOfSelection {
                cell.setCell(disable: true)
            }
            cell.checkBoxImageView.isHidden = true
            let bundle = Bundle(for: ImageCollectionViewCell.self)
            let url = bundle.url(forResource: "OMGImagePicker", withExtension: "bundle")
            cell.thumbnailImage = UIImage(named: "add_photo", in: Bundle(url:url!), compatibleWith: nil)
        } else {
            let asset = fetchResult[indexPath.row - 1]
            cell.checkBoxImageView.isHidden = false
            cell.representedAssetIdentifier = asset.localIdentifier
            cell.isSelected = false
            if selectionPhotoIdentifier.count >= setting.maxNumberOfSelection {
                if !selectionPhotoIdentifier.contains(asset.localIdentifier) {
                    cell.setCell(disable: true)
                }
            }
            
            if selectionPhotoIdentifier.contains(asset.localIdentifier) {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            }
            let  imageManager = PHCachingImageManager()
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .default, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.thumbnailImage = image
                }
            })
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count + 1
    }
    
}

// MARK: - UICollectionViewDelegate
extension OMGImagePickerViewController:UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectionPhotoIdentifier.count < setting.maxNumberOfSelection else {
            return
        }
        
        if indexPath.row == 0 {
            #if (arch(i386) || arch(x86_64))
                // we're on the simulator - calculate pretend movement
            #else
                let pickerViewController = UIImagePickerController()
                pickerViewController.sourceType = .camera
                pickerViewController.delegate = self
                present(pickerViewController, animated: true, completion: nil)
            #endif
        } else if let cell = collectionView.cellForItem(at: indexPath) as?  ImageCollectionViewCell {
            selectionPhotoIdentifier.append(cell.representedAssetIdentifier)
            if selectionPhotoIdentifier.count >= setting.maxNumberOfSelection {
                collectionView.visibleCells.forEach{ cell in
                    if let imageCell = cell as? ImageCollectionViewCell {
                        if !selectionPhotoIdentifier.contains(imageCell.representedAssetIdentifier) {
                            imageCell.setCell(disable: true)
                        }
                    }
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as?  ImageCollectionViewCell {
            selectionPhotoIdentifier.remove(object: cell.representedAssetIdentifier)
            collectionView.visibleCells.forEach{ cell in
                if let imageCell = cell as? ImageCollectionViewCell {
                    imageCell.setCell(disable: false)
                }
            }
        }
    }
    
}

// MARK: - UINavigationControllerDelegate,UIImagePickerControllerDelegate
extension OMGImagePickerViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard  let original = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        collectionView?.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
        addAsset(image: original)
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

// MARK: - Private Method
private extension OMGImagePickerViewController {
    func viewSetup()  {
        navigationController?.navigationBar.barTintColor = setting.navigationBarColor
        navigationController?.navigationBar.isTranslucent = setting.navigationBarTranslucent
        let lefeBarButton = UIBarButtonItem(title: setting.leftBarTitle, style: .plain, target: self, action: .leftBarButtonAction)
        lefeBarButton.tintColor = UIColor.red
        navigationItem.leftBarButtonItem = lefeBarButton
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            activityIndicatorView.center = view.center
            activityIndicatorView.hidesWhenStopped = true
            view.addSubview(activityIndicatorView)
            PHPhotoLibrary.shared().register(self)
            if fetchResult == nil {
                let allPhotosOptions = PHFetchOptions()
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
            }
            
            flowLayout = UICollectionViewFlowLayout()
            let itemSize = view.frame.width / 4 - 1
            flowLayout?.itemSize =  CGSize(width: itemSize, height: itemSize)
            flowLayout?.minimumInteritemSpacing = 1
            flowLayout?.minimumLineSpacing = 1
            collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout!)
            collectionView?.translatesAutoresizingMaskIntoConstraints = false
            collectionView?.backgroundColor = UIColor.white
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ImageCollectionViewCell.self))
            collectionView?.allowsMultipleSelection = true
            view.addSubview(collectionView!)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView":collectionView]))
            
            let rightBarButton = UIBarButtonItem(title: setting.rightBarTitle, style: .plain, target: self, action: .rightBarButtonAction)
            rightBarButton.tintColor = UIColor.gray
            navigationItem.rightBarButtonItem = rightBarButton
            self.rightBarButton = rightBarButton
            
            let albumSelectButton = UIButton(type: .custom)
            albumSelectButton.setTitle(" All Photo", for: .normal)
            albumSelectButton.setTitleColor(UIColor.black, for: .normal)
            let bundle = Bundle(for: ImageCollectionViewCell.self)
            let url = bundle.url(forResource: "OMGImagePicker", withExtension: "bundle")
            albumSelectButton.setImage(UIImage(named: "arrow_down", in: Bundle(url:url!), compatibleWith: nil), for: .normal)
            albumSelectButton.frame = CGRect(x: 0, y: 0, width: 200, height: 22)
            albumSelectButton.addTarget(self, action: .showAlbumAction, for: .touchUpInside)
            navigationItem.titleView = albumSelectButton
            self.albumSelectButton = albumSelectButton
        } else {
            if let authorizeView = delegate?.userDeniedAuthPhotosView(imagePickerViewController: self) {
                authorizeView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(authorizeView)
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[authorizeView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["authorizeView":authorizeView]))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[authorizeView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["authorizeView":authorizeView]))
            } else {
                let authorizeView = UIView()
                authorizeView.backgroundColor = UIColor.white
                authorizeView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(authorizeView)
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[authorizeView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["authorizeView":authorizeView]))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[authorizeView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["authorizeView":authorizeView]))
                let titleLable = UILabel()
                titleLable.textAlignment = .center
                titleLable.text = "This app does not have access to your photo or videos."
                titleLable.translatesAutoresizingMaskIntoConstraints = false
                
                titleLable.numberOfLines = 0
                
                if #available(iOS 9.0, *) {
                    titleLable.font = UIFont.preferredFont(forTextStyle: .title3)
                } else {
                    titleLable.font = UIFont.preferredFont(forTextStyle: .headline)
                }
                authorizeView.addSubview(titleLable)
                
                let body = UILabel()
                body.text = "You can enable access in Privacy Settings."
                body.textAlignment = .center
                
                body.font = UIFont.preferredFont(forTextStyle: .subheadline)
                
                body.translatesAutoresizingMaskIntoConstraints = false
                
                body.numberOfLines = 0
                body.textColor = UIColor.gray
                authorizeView.addSubview(body)
                
                view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.centerY, multiplier: 0.5, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 8))
                view.addConstraint(NSLayoutConstraint(item: titleLable, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -8))
                
                view.addConstraint(NSLayoutConstraint(item: body, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: body, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleLable, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10))
                view.addConstraint(NSLayoutConstraint(item: body, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 8))
                view.addConstraint(NSLayoutConstraint(item: body, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -8))
                
                let enableButton = UIButton(type: .custom)
                enableButton.setTitle("Enable", for: .normal)
                enableButton.translatesAutoresizingMaskIntoConstraints = false
                enableButton.setTitleColor(UIColor.blue, for: .normal)
                authorizeView.addSubview(enableButton)
                view.addConstraint(NSLayoutConstraint(item: enableButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: authorizeView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: enableButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: body, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10))
                enableButton.addTarget(self, action: .enableAccessPhotoAction, for: .touchUpInside)
            }
        }
    }
    
    @objc func showAlbumSelectViewController(_ sender: UIButton) {
      
        let albumViewController =  AlbumTableViewController(style: .plain)
        albumViewController.delegate = self
        albumViewController.modalPresentationStyle = .popover
        albumViewController.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height * 0.75)
        
        if let pctrl = albumViewController.popoverPresentationController {
            pctrl.backgroundColor = UIColor.white
            pctrl.delegate = self
            pctrl.sourceView = sender
            pctrl.sourceRect = sender.bounds
            present(albumViewController, animated: true, completion: nil)
        }
        
    }
    
    @objc func done()   {
        guard selectionPhotoIdentifier.count > 0 else {
            return
        }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: selectionPhotoIdentifier, options: nil)
        delegate?.imagePickerViewController(imagePickerViewController: self, didFinishPickingWith: assets)
    }
    
    @objc func cancel () {
        delegate?.imagePickerViewControllerDidCancel(imagePickerViewController: self)
    }
    
   @objc  func enableAccessPhoto()  {
        let url = NSURL(string: UIApplicationOpenSettingsURLString) as! URL
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if #available(iOS 9.0, *) {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension OMGImagePickerViewController:UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - AlbumTableViewControllerDelegate
extension OMGImagePickerViewController:AlbumTableViewControllerDelegate {
    func albumViewController(vc: AlbumTableViewController, didSelect assetCollection: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        albumSelectButton.setTitle(" \(assetCollection.localizedTitle ?? "")", for: .normal)
        self.selectAssetCollection = assetCollection
        vc.dismiss(animated: true, completion: nil)
    }
    
    func albumViewController(vc: AlbumTableViewController, didAllPhoto result: PHFetchResult<PHAsset>) {
        self.fetchResult = result
        albumSelectButton.setTitle(" All Photo", for: .normal)
        vc.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension OMGImagePickerViewController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                if changeDetails.fetchResultAfterChanges.count != fetchResult.count {
                    fetchResult = changeDetails.fetchResultAfterChanges
                }
                
                activityIndicatorView.stopAnimating()
                collectionView?.isUserInteractionEnabled = true
            }
        }
    }
    
    func addAsset(image: UIImage) {
        var placeholderAsset:PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let selectAssetCollection = self.selectAssetCollection {
                guard let addAssetRequest = PHAssetCollectionChangeRequest(for: selectAssetCollection)
                    else { return }
                addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
            placeholderAsset =  creationRequest.placeholderForCreatedAsset
        }, completionHandler: { success, error in
            if !success { NSLog("error creating asset: \(error)") }
            guard let identifier = placeholderAsset?.localIdentifier else {return}
            self.selectionPhotoIdentifier.append(identifier)
        })
    }
}

fileprivate extension Selector {
    static let rightBarButtonAction = #selector(OMGImagePickerViewController.done)
    static let leftBarButtonAction = #selector(OMGImagePickerViewController.cancel)
    static let showAlbumAction = #selector(OMGImagePickerViewController.showAlbumSelectViewController(_:))
    static let enableAccessPhotoAction = #selector(OMGImagePickerViewController.enableAccessPhoto)
}

fileprivate extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
