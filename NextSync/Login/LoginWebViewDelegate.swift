//
//  LoginWebViewDelegate.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import WebKit

class LoginWebNavigationDelegate: NSObject, WKNavigationDelegate {
    private static let ncScheme = "nc://"

    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        guard let url = webView.url else { return }
        print(url, url.scheme)
        //if url.scheme ==
    }
}
