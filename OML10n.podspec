Pod::Spec.new do |s|

  s.name         = "OML10n"
  s.version      = "0.1"
  s.summary      = "A tool for live remote localization."
  s.description  = <<-DESC
    This is an addition to the development process
    for handling remote localization on-the-fly
                   DESC
  s.homepage     = "https://github.com/OnMap/L10n-iOS"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "OnMap" => "info@onmap.co.il" }
  s.source       = { :git => "https://github.com/OnMap/L10n-iOS.git", :tag => "#{s.version}" }

  s.platform     = :ios, "9.0"  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.framework      = 'Foundation'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/**/*.{swift,stringsdict}'
  end

  s.subspec 'LiveUpdates' do |liveupdates|
    liveupdates.source_files = 'Source/LiveUpdates/**/*.swift'
    liveupdates.dependency 'OML10n/Core'
    liveupdates.dependency "RealmSwift", "~> 3.1"
    liveupdates.dependency "RxSwift", "~> 4.1"
    liveupdates.dependency "RxCocoa", "~> 4.1"
    liveupdates.dependency 'RxRealm', '~> 0.7'
    liveupdates.dependency 'NSObject+Rx', '~> 4.2'
  end
  
  s.subspec 'Parseltongue' do |parseltongue|
    parseltongue.source_files = 'Source/Parseltongue/**/*.swift'
    parseltongue.dependency 'OML10n/LiveUpdates'
    parseltongue.dependency 'Socket.IO-Client-Swift', '~> 13.1'
  end

end
