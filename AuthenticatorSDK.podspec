Pod::Spec.new do |s|
  s.name = 'AuthenticatorSDK'
  s.version = '4.0.0'
  s.license = 'MIT'
  s.summary = 'Authenticator SDK. Instant two-factor authentication for cloud-based services'
  s.homepage = 'https://github.com/cmdisp/authenticator-sdk-ios'
  s.authors = 'CM Telecom'
  s.source = { :git => 'https://github.com/cmdisp/authenticator-sdk-ios.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Source/**/*.{h,swift}'
  s.requires_arc = true
end