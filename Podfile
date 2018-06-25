platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

target 'Trust' do
  use_frameworks!

  pod 'BigInt', '~> 3.0'
  pod 'R.swift'
  pod 'JSONRPCKit', :git=> 'https://github.com/bricklife/JSONRPCKit.git'
  pod 'PromiseKit', '~> 6.0'
  pod 'APIKit'
  pod 'Eureka', '~> 4.1.1'
  pod 'MBProgressHUD'
  pod 'StatefulViewController'
  pod 'QRCodeReaderViewController', :git=>'https://github.com/yannickl/QRCodeReaderViewController.git', :branch=>'master'
  pod 'KeychainSwift'
  pod 'SwiftLint'
  pod 'SeedStackViewController'
  pod 'RealmSwift'
  pod 'Lokalise'
  pod 'Moya', '~> 10.0.1'
  pod 'CryptoSwift', :git=>'https://github.com/krzyzanowskim/CryptoSwift', :branch=>'master'
  pod 'Fabric'
  pod 'Crashlytics', '~> 3.10'
  pod 'Kingfisher', '~> 4.0'
  pod 'TrustCore', '~> 0.0.7'
  pod 'TrustKeystore', :git=>'https://github.com/TrustWallet/trust-keystore', :branch=>'master'
  pod 'Branch'
  pod 'SAMKeychain'
  pod 'TrustWeb3Provider', :git=>'https://github.com/TrustWallet/trust-web3-provider', :branch=>'master'
  pod 'JdenticonSwift'
  pod 'URLNavigator'
  pod 'RandomColorSwift'
  pod 'TrustWalletSDK', :git=>'https://github.com/TrustWallet/TrustSDK-iOS', :branch=>'master'

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
    if ['JSONRPCKit'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    if ['TrustKeystore'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
