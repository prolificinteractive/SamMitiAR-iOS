Pod::Spec.new do |spec|
  spec.platform     = :ios, "11.3"
  spec.name         = 'SamMitiAR'
  spec.version      = '1.0.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/prolificinteractive/SamMitiAR-iOS'
  spec.authors      = { 'Nattawut Singhchai' => 'wut@prolificinteractive.com' }
  spec.summary      = 'Ready-and-easy-to-use ARKit framework for the best user experience.'
  spec.source       = { :git => 'https://github.com/prolificinteractive/SamMitiAR-iOS.git', :tag => spec.version.to_s }
  spec.dependency "GLTFSceneKit", "~>0.1"
  spec.source_files = 'SamMiti/**/*.{swift,h}'
  spec.resources = ["SamMiti/**/*.{storyboard,xib,strings}", "SamMiti/SamMitiArt.scnassets", "SamMiti/SamMitiAssets.xcassets"]

end
