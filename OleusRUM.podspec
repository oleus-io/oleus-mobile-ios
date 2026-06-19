Pod::Spec.new do |s|
  s.name             = 'OleusRUM'
  s.version          = '0.8.1'
  s.summary          = 'Oleus Real User Monitoring SDK for iOS and macOS.'

  s.description      = <<-DESC
    OleusRUM captures sessions, views, user actions, network requests, crashes,
    and session replay from your iOS/macOS app and ships them to the Oleus platform.
  DESC

  s.homepage         = 'https://github.com/oleus-io/oleus-rum-ios'
  s.license          = { :type => 'Commercial', :text => 'Copyright (c) Oleus. All rights reserved.' }
  s.author           = { 'Oleus' => 'sdk@oleus.io' }

  s.source           = { :git => 'https://github.com/oleus-io/oleus-rum-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '12.0'
  s.swift_version    = '5.9'

  s.source_files     = 'Sources/OleusRUM/**/*.swift'
  s.frameworks       = 'Foundation'
end
