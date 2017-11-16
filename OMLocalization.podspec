Pod::Spec.new do |s|

  s.name         = "OMLocalization"
  s.version      = "0.3"
  s.summary      = "A tool for live remote localization."
  s.description  = <<-DESC
    This is an addition to the development process
    for handling remote localization on-the-fly
                   DESC
  s.homepage     = "https://github.com/onmap/Localization"
  s.license      = "MIT"
  s.author       = { "OnMap" => "info@onmap.co.il" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/OnMap/OMLocalization-iOS.git", :tag => "#{s.version}" }
  s.source_files  = "Source/**/*.swift"

  s.framework      = 'Foundation'

  s.dependency "RealmSwift", "~> 3.0.0"
  s.dependency "RxSwift", "~> 4.0.0"
  s.dependency 'RxRealm', '~> 0.7.0'
  s.dependency 'NSObject+Rx', '~> 4.2.0'
  s.dependency 'Socket.IO-Client-Swift', '~> 12.1.0'

end
