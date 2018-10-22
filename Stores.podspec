Pod::Spec.new do |s|
  s.name             = 'Stores'
  s.version          = '0.1.0'
  s.summary          = 'A simple wrapper around Keychain and UserDefaults'
  s.description      = s.summary

  s.homepage         = 'https://github.com/CoinbaseWallet/Stores'
  s.license          = { :type => "AGPL-3.0-only", :file => 'LICENSE' }
  s.author           = { 'Coinbase' => 'developer@toshi.org' }
  s.source           = { :git => 'https://github.com/CoinbaseWallet/Stores.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/coinbase'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.source_files = 'Stores/**/*'

  s.dependency 'RxSwift', '~> 4.3.0'
end
