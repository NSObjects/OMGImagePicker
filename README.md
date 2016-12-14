# OMGImagePicker
![ImagePickerView](https://github.com/NSObjects/OMGImagePicker/blob/master/Document/Demo.gif)

[![CI Status][image-1]][2]
[![Version][image-2]][3]
[![License][image-3]][4]
[![Platform][image-4]][5]

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
	let pickViewController = OMGImagePickerViewController()
	pickViewController.delegate = self
	let navigationController = UINavigationController(rootViewController: pickViewController)
	present(navigationController, animated: true, completion: nil)

OMGImagePickerViewController  has two delegate methods that will inform you what the users are up to:
	func imagePickerViewController(vc:OMGImagePickerViewController,didFinishPickingWith assets:PHFetchResult<PHAsset>)
	func imagePickerViewControllerDidCancel(vc:OMGImagePickerViewController)

### Configuration
	pickViewController.maxNumberOfSelections = 5 // Defaults is 3
	pickViewController.rightButtonTitle = "Done" // Default is Continue

## Installation

OMGImagePicker is available through [CocoaPods][6]. To install
it, simply add the following line to your Podfile:


	pod "OMGImagePicker"


## Author

NSObjects, mrqter@gmail.com

## License

OMGImagePicker is available under the MIT license. See the LICENSE file for more info.

[2]:	https://travis-ci.org/NSObjects/OMGImagePicker
[3]:	http://cocoapods.org/pods/OMGImagePicker
[4]:	http://cocoapods.org/pods/OMGImagePicker
[5]:	http://cocoapods.org/pods/OMGImagePicker
[6]:	http://cocoapods.org

[image-1]:	http://img.shields.io/travis/NSObjects/OMGImagePicker.svg?style=flat
[image-2]:	https://img.shields.io/cocoapods/v/OMGImagePicker.svg?style=flat
[image-3]:	https://img.shields.io/cocoapods/l/OMGImagePicker.svg?style=flat
[image-4]:	https://img.shields.io/cocoapods/p/OMGImagePicker.svg?style=flat
