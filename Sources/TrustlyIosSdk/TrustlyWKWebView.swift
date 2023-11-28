/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2020 Trustly Group AB
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import WebKit


/// Invoked when the TrustlyWebView has successfully completed an order.
///
/// - Note: The webview will not autoclose and you can use this closure to dismiss the web view yourself.
public typealias TrustlyWebViewOnSuccess = () -> Void

/// Invoked when the TrustlyWebView has encountered an error.
///
/// - Note: The webview will not autoclose and you can use this closure to dismiss the web view yourself.
public typealias TrustlyWebViewOnError = () -> Void

/// Invoked when the TrustlyWebView flow was aborted by the user.
///
/// - Note: The webview will not autoclose and you can use this closure to dismiss the web view yourself.
public typealias TrustlyWebViewOnAbort = () -> Void


/// A wrapper around WKWebView allowing communication with the Trustly checkout.
///
/// The checkout passes events (success, error and abort)  to the web view. T
/// Through `onSuccess`, `onAbort` and `onError` variables you you can provide your own
/// custom logic for those events
/// - Note if no custom event handling is provided, the web view will load the `SuccessURL` for success events
///  or `FailURL` for error and abort events. The value of these parameters is passed by your backend API call to the
///  Trustly backend.
/// - See  https://eu.developers.trustly.com/doc/docs/order-initiation
public class TrustlyWKWebView: UIView, WKNavigationDelegate, WKUIDelegate, TrustlyWKScriptHandlerDelegate  {

    /// Custom closure that will be invoked when the Trustly checkout has successfully completed an order.
    public var onSuccess: TrustlyWebViewOnSuccess?
    /// Custom closure that will be invoked when the Trustly checkout has encountered an error.
    public var onError: TrustlyWebViewOnError?
    /// Custom closure that will be invoked when the Trustly checkout was aborted by end user.
    public var onAbort: TrustlyWebViewOnAbort?

    var webView: WKWebView?
    var trustlyWKScriptHandler: TrustlyWKScriptHandler!

    public init?(checkoutUrl: String, frame: CGRect) {
        super.init(frame: frame)

        let userContentController: WKUserContentController = WKUserContentController()
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: frame, configuration: configuration)
        guard let webView = webView else { return nil }

        webView.navigationDelegate = self
        webView.uiDelegate = self

        trustlyWKScriptHandler = TrustlyWKScriptHandler(webView: webView, delegate: self)
        userContentController.add(trustlyWKScriptHandler, name: TrustlyWKScriptHandler.NAME)
           
        if let url = URL(string: checkoutUrl) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }

        addSubview(webView)
    }
    
    static let IS_RETURN_FROM_APP = "isReturnFromApp"
    
    // Only supported from v4.0.1 and up
    public func setReturnedFromApp() {
        if let checkoutUrl = webView?.url?.absoluteString {
            
            // Append a random number to the hash param to ensure we skip page reloads
            let randomString = String(Int.random(in: 0..<Int.max))
            let separator = checkoutUrl.contains("#") ? "&" : "#"
            let checkoutUrlWithHash = "\(checkoutUrl)\(separator)\(TrustlyWKWebView.IS_RETURN_FROM_APP)=\(randomString)"
            
            if let url = URL(string: checkoutUrlWithHash) {
                webView?.load(URLRequest(url: url))
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func trustlyWKScriptHandlerOnSuccess() {
        if let onSuccess = onSuccess {
            onSuccess()
        }
    }

    internal func trustlyWKScriptHandlerOnError() {
        if let onError = onError {
            onError()
        }
    }

    internal func trustlyWKScriptHandlerOnAbort() {
        if let onAbort = onAbort {
            onAbort()
        }
    }

}
