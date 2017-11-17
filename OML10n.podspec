Pod::Spec.new do |s|

  s.name         = "OML10n"
  s.version      = "0.1"
  s.summary      = "A tool for live remote localization."
  s.description  = <<-DESC
    This is an addition to the development process
    for handling remote localization on-the-fly
                   DESC
  s.homepage     = "https://github.com/OnMap/OML10n-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "OnMap" => "info@onmap.co.il" }
  s.source       = { :git => "https://github.com/OnMap/OML10n-iOS.git", :tag => "#{s.version}" }

  s.platform     = :ios, "9.0"  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.framework      = 'Foundation'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/**/*.{swift,stringsdict}'
  end

  s.subspec 'IBInspectable' do |inspectable|
    inspectable.dependency 'OML10n/Core'
    inspectable.source_files = 'Source/IBInspectable/**/*.swift'
  end

  s.subspec 'LiveUpdates' do |liveupdates|
    liveupdates.dependency 'OML10n/Core'
    liveupdates.source_files = 'Source/LiveUpdates/**/*.swift'
    liveupdates.dependency "RealmSwift", "~> 3.0.0"
    liveupdates.dependency "RxSwift", "~> 4.0.0"
    liveupdates.dependency 'RxRealm', '~> 0.7.0'
    liveupdates.dependency 'NSObject+Rx', '~> 4.2.0'
  end
  
  s.subspec 'Parseltongue' do |parseltongue|
    parseltongue.dependency 'OML10n/LiveUpdates'
    parseltongue.source_files = 'Source/LiveUpdates/**/*.swift'
    parseltongue.dependency 'Socket.IO-Client-Swift', '~> 12.1.0'    
  end

end
