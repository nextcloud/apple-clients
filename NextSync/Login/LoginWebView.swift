//
//  LoginWebView.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI
import WebKit

struct LoginWebView: View {
    let navigationDelegate = LoginWebNavigationDelegate()
    let configuration = WKWebViewConfiguration()
    let request: URLRequest

    init(serverUrl: URL) {
        var request = URLRequest(url: serverUrl)
        request.addValue("true", forHTTPHeaderField: "OCS-APIRequest")
        if let language = Locale.preferredLanguages.first {
            request.addValue(language, forHTTPHeaderField: "Accept-Language")
        }
        self.request = request
        configuration.websiteDataStore = .nonPersistent()
    }

    var body: some View {
        WebViewRepresentable(request: request, configuration: configuration) { view in
            view.navigationDelegate = navigationDelegate
        }
    }
}
