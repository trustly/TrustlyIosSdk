# Trustly iOS SDK

The Trustly iOS SDK provides an easy way to implement the Trustly Checkout in your iOS app. The SDK handles communication with the Web View and exposes Checkout events that allows you to customize your Checkout flow. 

**`Note: The latest version of the SDK does not support the older version of the Trustly Checkout. If you do use the older version of the Checkout, please use version 2.0.0 of the SDK. If you are not sure what version of the Trustly Checkout you are using, please contact our intergration support.`**

## Integration
Add the SDK as a Swift Package. [More detailed intructions can be found here.](https://www.trustly.net/site/developer-portal?part=iosandroid)
1. Navigate to File -> Swift Packages -> Add Package Dependency.
2. Paste the Trustly SDK URL: https://github.com/trustly/TrustlyIosSdk
3. Select Up to Next Major version and make sure you have the latest version
4. Press finish.
5. You should now see the swift package in the project navigator.

## Usage
Pass your Checkout URL when initialising a new TrustlyWKWebView instance. The Checkout will be rendered within the TrustlyWKWebView.

Example usage:
```swift
let webViewController = UIViewController.init(nibName: nil, bundle: nil)
let mainView = TrustlyWKWebView(checkoutUrl: your_trustly_checkout_url.absoluteString, frame: self.view.bounds)
webViewController.view = mainView
show(webViewController, sender: nil)
```
### Receiving Checkout Events
If you want more control of your Checkout flow you can choose to opt-in to receiving and handling Checkout events. 

You can opt-in by providing `onSuccess` and `onError` closures.


## Notes about URLScheme
Please note that when rendering the Trustly Checkout from a native app you are required to pass your application’s [URLScheme](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) as an attribute to the order initiation request. By doing so, Trustly can redirect users back to your app after using external identification apps such as Mobile BankID. You can pass your URLScheme by including it in the "URLScheme" attribute when making an API call to Trustly. [You can read more about it here.](https://developers.trustly.com/emea/docs/ios)
