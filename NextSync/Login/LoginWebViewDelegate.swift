//
//  LoginWebViewDelegate.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI
import WebKit

@Observable class LoginWebNavigationDelegate: NSObject, WKNavigationDelegate {
    var finished = false

    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        guard let url = webView.url else { return }
        let urlString = url.absoluteString
        if urlString.hasPrefix(URLSchemeHandler.scheme) {
            // We are done, go back and let the URL scheme handler take it from here
            finished = true
        }
    }
}
