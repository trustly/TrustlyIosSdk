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

internal enum TrustlyCheckoutEvent: String {
    case openURLScheme = "onTrustlyCheckoutRedirect"
    case success = "onTrustlyCheckoutSuccess"
    case error = "onTrustlyCheckoutError"
    case abort = "onTrustlyCheckoutAbort"
}

internal protocol TrustlyWKScriptHandlerDelegate: AnyObject {
    func trustlyWKScriptHandlerOnSuccess();
    func trustlyWKScriptHandlerOnError();
    func trustlyWKScriptHandlerOnAbort();
}

internal class TrustlyWKScriptHandler: NSObject, WKScriptMessageHandler {

    weak var delegate: TrustlyWKScriptHandlerDelegate?
    /// Name of the "native bridge" that will be used to communicate with the web view.
    static let NAME = "trustlySDKBridge"
    
    init(delegate: TrustlyWKScriptHandlerDelegate) {
        self.delegate = delegate
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard let parsedCheckoutEventObject = getParsedJSON(object: message.body as AnyObject) else {
            print("TRUSTLY SDK: Message posted from script handler has an invalid format")
            return
        }

        guard let eventType = parsedCheckoutEventObject.object(forKey: "type") as? String else {
            print("TRUSTLY SDK: Found no type property on checkout event")
            return
        }

        guard let trustlyCheckoutEvent = TrustlyCheckoutEvent(rawValue: eventType) else {
            print("TRUSTLY SDK: Checkout event type not recognized")
            return
        }
        let urlString: String? = parsedCheckoutEventObject.object(forKey: "url") as? String ?? nil

        handleCheckoutEvent(checkoutEvent: trustlyCheckoutEvent, URLString: urlString);
    }

    func handleOpenRedirectURL (URLString: String?) {
        guard let URLString = URLString else {
            print("TRUSTLY SDK: Checkout event type .onTrustlyCheckoutRedirect - No redirect URL found")
            return;
        }
        if let URL = URL(string: URLString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL, options: [:])
                { opened in
                    if (!opened) {
                        print ("TRUSTLY SDK: Checkout event type .onTrustlyCheckoutRedirect - Unable to open URL: \(URL)")
                    }
            } else {
                UIApplication.shared.openURL(URL)
            }
        }
    }

    func handleCheckoutEvent(checkoutEvent: TrustlyCheckoutEvent, URLString: String?) {
        switch checkoutEvent {
            case .openURLScheme: handleOpenRedirectURL(URLString: URLString)
            case .success: delegate?.trustlyWKScriptHandlerOnSuccess()
            case .error: delegate?.trustlyWKScriptHandlerOnError()
            case .abort: delegate?.trustlyWKScriptHandlerOnAbort()
        }
    }
}


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

