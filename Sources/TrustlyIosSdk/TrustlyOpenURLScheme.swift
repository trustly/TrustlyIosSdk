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

public class TrustlyWKScriptOpenURLScheme: NSObject, WKScriptMessageHandler {

    weak var trustlyCheckoutDelegate: TrustlyCheckoutDelegate?

    var webView: WKWebView

    /// Name of the "native bridge" that will be used to communicate with the web view.
    public static let NAME = "trustlySDKBridge"
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    /**
        Function to handle messages from the web client rendered in the Web View.
     */
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let parsedCheckoutEventObject = getParsedJSON(object: message.body as AnyObject) else {
            print("TRUSTLY SDK: Message posted from script handler has an invalid format")
            return
        }
        
        /// Check if the SDK user have opted into using TrustlyCheckoutEventDelegate
        if trustlyCheckoutDelegate != nil {
            handleCheckoutEvent(jsonObject: parsedCheckoutEventObject)
            return
        }
        
        /// Handle the message the legacy way to ensure backwards compability.
        if let callback: String = parsedCheckoutEventObject.object(forKey: "callback") as? String,
        let urlscheme: String = parsedCheckoutEventObject.object(forKey: "urlscheme") as? String
        {
            UIApplication.shared.openURL(NSURL(string: urlscheme)! as URL)
            let js: String = String(format: "%@", [callback, urlscheme])
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    /**
        Validate and call the correct delegate method for the event.
        - Parameter jsonObject: The json object sent from the Web Client.
    */
    func handleCheckoutEvent(jsonObject: NSDictionary) {
        
        guard let eventType = jsonObject.object(forKey: "type") as? String else {
            print("TRUSTLY SDK: Found no type property on checkout event")
            return
        }
        
        guard let trustlyCheckoutEvent = TrustlyCheckoutEvent(rawValue: eventType) else {
            print("TRUSTLY SDK: Checkout event type not recognized")
            return
        }
        
        let url: String? = jsonObject.object(forKey: "url") as? String ?? nil
    
        switch trustlyCheckoutEvent {
        case .openURLScheme:
            if let urlSchemeString = url as String? {
                self.trustlyCheckoutDelegate?.onTrustlyCheckoutRequstToOpenURLScheme(urlScheme: urlSchemeString)
            }
        case .success:
            self.trustlyCheckoutDelegate?.onTrustlyCheckoutSuccessfull(urlString: url)
        case .error:
            self.trustlyCheckoutDelegate?.onTrustlyCheckoutError()
        case .abort:
            self.trustlyCheckoutDelegate?.onTrustlyCheckoutAbort(urlString: url)
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
