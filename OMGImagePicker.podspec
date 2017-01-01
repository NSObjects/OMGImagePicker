Pod::Spec.new do |s|
  s.name             = 'OMGImagePicker'
  s.version          = '1.0.0'
  s.summary          = 'A image picker library.'

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

end
