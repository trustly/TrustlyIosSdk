# Trustly iOS SDK

The Trustly iOS SDK provides an easy way to implement the Trustly Checkout in your iOS app. The SDK handles communication with the Web View and exposes Checkout events that allows you to customize your Checkout flow. 

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
let trustlyWebView = TrustlyWKWebView(checkoutUrl: trustlyCheckoutURLString, frame: self.view.frame)
self.view = trustlyWebView 
```
### Receiving Checkout Events
If you want more control of your Checkout flow you can choose to opt-in to receiving and handling Checkout events. 

You can opt-in by setting the delegate of the TrustlyWKWebView 
```swift
trustlyWebView?.delegate = self
```
and conforming to the TrustlyCheckoutDelegate protocol
```swift
class ViewController: UIViewController, TrustlyCheckoutDelegate {
    
    func onTrustlyCheckoutRequstToOpenURLScheme(urlScheme: String) {
        //Requests to open URLs or third party applications.
    }
    
    func onTrustlyCheckoutSuccessfull(urlString: String?) {
        
    }
    
    func onTrustlyCheckoutError() {
        
    }
    
    func onTrustlyCheckoutAbort(urlString: String?) {
        
    }
}
```

## Notes about URLScheme
Please note that when rendering the Trustly Checkout from a native app you are required to pass your application’s [URLScheme](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) as an attribute to the order initiation request. By doing so, Trustly can redirect users back to your app after using external identification apps such as Mobile BankID. You can pass your URLScheme by including it in the "URLScheme" attribute when making an API call to Trustly. [You can read more about it here.](https://www.trustly.net/site/developer-portal?part=iosandroid)
