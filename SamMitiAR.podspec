Pod::Spec.new do |spec|
  spec.platform     = :ios, "11.0"
  spec.name         = 'SamMitiAR'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://bitbucket.org/prolificinteractive/sammiti-ios'
  spec.authors      = { 'Nattawut Singhchai' => 'wut@prolificinteractive.com' }
  spec.summary      = 'An iOS framework for easy 3D thing integration to your application.'
  spec.source       = { :git => 'git@bitbucket.org:prolificinteractive/sammiti-ios.git', :tag => spec.version.to_s }
  spec.dependency "GLTFSceneKit", "~>0.1"
  spec.source_files = 'SamMiti/**/*.{swift,h}'
  spec.resources = ["SamMiti/**/*.{storyboard,xib,strings}", "SamMiti/SamMitiArt.scnassets", "SamMiti/SamMitiAssets.xcassets"]

end
