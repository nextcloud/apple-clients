//
//  LoginWebViewDelegate.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import OSLog
import SwiftUI
import WebKit

@Observable class LoginWebNavigationDelegate: NSObject, WKNavigationDelegate {
    var finished = false
    private let logger = Logger(subsystem: Logger.subsystem, category: "login-web-nav-delegate")

    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        guard let url = webView.url else { return }
        let urlString = url.absoluteString
        logger.debug("Received url \(urlString)")
        if urlString.hasPrefix(URLSchemeHandler.scheme) {
            // We are done, go back and let the URL scheme handler take it from here
            finished = true
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        logger.debug("Received url decision to make for \(navigationAction.request.url?.absoluteString ?? "")")
        if let url = navigationAction.request.url, url.scheme == URLSchemeHandler.scheme {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
            finished = true
            decisionHandler(.cancel)
        } else {
            // allow the request
            decisionHandler(.allow)
        }
    }
}
