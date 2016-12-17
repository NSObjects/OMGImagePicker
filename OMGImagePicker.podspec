#
# Be sure to run `pod lib lint OMGImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OMGImagePicker'
  s.version          = '0.1.3'
  s.summary          = 'A image picker library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        A simple image picker view controller for swift 3
                       DESC

  s.homepage         = 'https://github.com/NSObjects/OMGImagePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NSObjects' => 'mrqter@gmail.com' }
  s.source           = { :git => 'https://github.com/NSObjects/OMGImagePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source_files = 'OMGImagePicker/Classes/**/*.swift'
  
  s.resource_bundles = {
    'OMGImagePicker' => ['OMGImagePicker/Assets/*.png']
  }

  s.framework     = "Photos"
  s.requires_arc  = true
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0',
  }

  #s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
