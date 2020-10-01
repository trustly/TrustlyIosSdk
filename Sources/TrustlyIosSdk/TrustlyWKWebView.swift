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
import SafariServices

public class TrustlyWKWebView: UIView, WKNavigationDelegate, WKUIDelegate, SFSafariViewControllerDelegate {
    var trustlyView: WKWebView?

    public init?(checkoutUrl: String, frame: CGRect) {
        super.init(frame: frame)

        let userContentController: WKUserContentController = WKUserContentController()
        let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        trustlyView = WKWebView(frame: frame, configuration: configuration)
        guard let trustlyView = trustlyView else { return nil }

        trustlyView.navigationDelegate = self
        trustlyView.uiDelegate = self
        trustlyView.navigationDelegate = self
        trustlyView.uiDelegate = self

        userContentController.add(
            TrustlyWKScriptOpenURLScheme(webView: trustlyView), name: TrustlyWKScriptOpenURLScheme.NAME)
        if let url = URL(string: checkoutUrl) {
            trustlyView.load(URLRequest(url: url))
            trustlyView.allowsBackForwardNavigationGestures = true
        }

        addSubview(trustlyView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            if let parentViewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController,
                let url = navigationAction.request.url {
                    let safariView = SFSafariViewController(url: url)
                    parentViewController.present(safariView, animated: true, completion: nil)
                    safariView.delegate = self
            }
        }

        return nil
    }
}
