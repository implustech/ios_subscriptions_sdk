Pod::Spec.new do |s|

  s.name                = "Apptilaus"
  s.version             = "1.0.4"
  s.summary             = "Subscription Analytics for Mobile Apps"
  s.description         = "Install Apptilaus SDK and analyse subscriptions from the App Store and other sources, manage your products and features delivery and process cross-platform purchases!"
  s.homepage            = "https://github.com/apptilaus/"
  s.social_media_url    = "https://facebook.com/apptilaus"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = { "Apptilaus" => "ios-sdk@apptilaus.com" }
  s.source              = { :git => "https://github.com/apptilaus/ios_subscriptions_sdk.git", :tag => s.version.to_s }

  s.ios.deployment_target = "9.0"
  s.framework           = "SystemConfiguration"
  s.ios.weak_framework  = "AdSupport", "iAd", "StoreKit"
  s.requires_arc        = true
  s.swift_version       = "4.2"

  s.documentation_url   = "https://apptilaus.com/docs"

  s.source_files        = "Sources/Apptilaus/*.{h,m,swift}"
  s.exclude_files       = "VERSION.md", "README.md", "Package.swift"

end