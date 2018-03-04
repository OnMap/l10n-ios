source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

workspace 'OML10n'

target 'OML10n' do
  project 'OML10n.xcodeproj'
  pod 'OML10n', :path => '.'
end

target 'Example' do
  project 'Example/Example.xcodeproj'
  pod 'OML10n', :path => '.'
end

target 'OML10nTests' do
    project 'OML10n.xcodeproj'
end

# Added as a temporary solution, mentioned here (https://stackoverflow.com/questions/48684825/multiple-warnings-using-realmswift-3-1-1-in-xcode-9?rq=1)
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = false
        end
    end
end
