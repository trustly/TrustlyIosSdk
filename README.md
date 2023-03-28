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
Please note that you are responsible for presentation and dismissal of the TrustlyWKWebView object.

Example usage:
```swift
let webViewController = UIViewController.init(nibName: nil, bundle: nil)
let trustlyWebView = TrustlyWKWebView(checkoutUrl: trustlyCheckoutURLString, frame: rect)
webViewController.view = trustlyWebView
show(webViewController, sender: nil)
```
### Receiving Checkout Events
If you want more control of your Checkout flow you can choose to provide custom handlers.

Provide `onSuccess`,`onError` and `onAbort` closures.
In case no custom functionality is provided, the webview will load the `SuccessURL`, in case of a success event, or the `FailURL` in case of a error or an abort event.
Read more https://eu.developers.trustly.com/doc/docs/order-initiation


```swift
let trustlyWebView = TrustlyWKWebView(checkoutUrl: trustlyCheckoutURLString, frame: rect)
guard let trustlyWebView = trustlyWebView {
    // handle wrong initialisation.
}
trustlyWebView.onSuccess = {
    // your custom implementation here.
}
trustlyWebView.onError = {
    // your custom implementation here.
}
trustlyWebView.onAbort = {
    // your custom implementation here.
}

```


## Automatic re-directs back to your application
It can happen that during the order flow, the user needs to be redirected outside of your application, to a third party application or website (in external stand alone browser). This could be part of the authentication and authorisation process.
To enable automatic re-directs back to your native application, you can pass a [deep link](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content) as an attribute to the order initiation request. You can pass your deep link (universal link or url scheme) value by including it in the "URLScheme" attribute when making an API call to Trustly. [You can read more about it here.](https://developers.trustly.com/emea/docs/ios)
