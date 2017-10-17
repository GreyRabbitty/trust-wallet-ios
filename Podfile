# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
inhibit_all_warnings!

target 'Trust' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'R.swift'
  pod 'JSONRPCKit', :git=> 'https://github.com/bricklife/JSONRPCKit.git'
  pod 'APIKit'
  pod 'Geth'
  pod 'EAIntroView'
  pod 'Eureka', :git=>'https://github.com/xmartlabs/Eureka.git', :branch=>'feature/Xcode9-Swift3_2'
  pod 'MBProgressHUD'
  pod 'StatefulViewController'
  pod 'QRCodeReaderViewController'
  pod 'KeychainSwift'
  pod 'SwiftLint'
  pod 'SeedStackViewController', :git=>'https://github.com/seedco/StackViewController.git', :branch=>'swift32'
  pod 'RealmSwift'
  pod 'BonMot'
  pod 'VENTouchLock'
  pod '1PasswordExtension'
  pod 'BulletinBoard', :git=>'https://github.com/alexaubry/BulletinBoard'
  pod 'Lokalise'
  pod 'Moya'
  pod 'JavaScriptKit'

  target 'TrustTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TrustUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
      installer.pods_project.targets.each do |target|
          if ['JavaScriptKit'].include? target.name
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
              end
          end
      end
  end
