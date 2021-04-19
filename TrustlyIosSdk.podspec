Pod::Spec.new do |spec|
  spec.name         = "TrustlyIosSdk"
  spec.version      = "3.0.0"
  spec.summary      = "The Trustly iOS SDK provides an easy way to implement the Trustly Checkout in your iOS app."
  spec.description  = <<-DESC
  The Trustly iOS SDK provides an easy way to implement the Trustly Checkout in your iOS app. The SDK handles communication with the Web View and exposes Checkout events that allows you to customize your Checkout flow.
                   DESC
  spec.homepage     = "https://github.com/trustly/TrustlyIosSdk"
  spec.license      = { :type => "MIT", :file => 'LICENSE' }
  spec.author    = "Trustly"
  spec.swift_version   = '5.3'
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/trustly/TrustlyIosSdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/TrustlyIosSdk/*.swift"
  spec.frameworks = "Foundation", "UIKit", "WebKit", "SafariServices"
end
