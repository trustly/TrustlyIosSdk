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

import Foundation
import WebKit

/**
 Will try to open the URL, then return result in callback
 :param: JSON
 */
public class TrustlyWKScriptOpenURLScheme: NSObject, WKScriptMessageHandler {

    public static let NAME = "trustlyOpenURLScheme"
    var webView: WKWebView

    public init(webView: WKWebView) {
        self.webView = webView
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let parsed = getParsedJSON(object: message.body as AnyObject),
        let callback: String = parsed.object(forKey: "callback") as? String,
        let urlscheme: String = parsed.object(forKey: "urlscheme") as? String
        {
            UIApplication.shared.openURL(NSURL(string: urlscheme)! as URL)
            let js: String = String(format: "%@", [callback, urlscheme])
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    /**
     Helper function that will try to parse AnyObject to JSON and return as NSDictionary
     :param: AnyObject
     :returns: JSON object as NSDictionary if parsing is successful, otherwise nil
     */
    func getParsedJSON(object: AnyObject) -> NSDictionary? {
        do {
            let jsonString: String = object as! String
            let jsonData = jsonString.data(using: String.Encoding.utf8)!
            let parsed = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            return parsed
        } catch let error as NSError {
            print("A JSON parsing error occurred:\n \(error)")
        }
        return nil
    }
}
