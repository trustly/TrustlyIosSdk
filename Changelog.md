# Changelog

## [4.0.1] - 2023-11-28
- Add setReturnedFromApp() method to TrustlyWKWebView. Can be called when Merchant-App is opened by urlscheme for a better user experience. This is an optional feature that is not yet rolled out in all Trustly products.

## [4.0.0] - 2023-03-21

### Removed
- Delegate events. 
- Trustly `.onRedirect` event is no longer publicly exposed as tampering with the redirect URL could cause isses with bank redirects

### Added
- Possibility for custom handlers for `.onSuccess`, `.onError` and `.onAbort` by providing closures. It's now possible to pick and choose for which events you want to provide custom handlers.

### Fixed
- Memory leak caused by reference cycle + improper clean up  of `WKWebViewConfiguration` script handler

### Changed
- minimum deployment target from iOS 9 to iOS 12
