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

    @Binding var serverUrl: URL?

    init(serverUrl: Binding<URL?>) {
        _serverUrl = serverUrl
        configuration.websiteDataStore = .nonPersistent()
    }

    var body: some View {
        WebView(url: serverUrl, configuration: configuration) { view in
            view.navigationDelegate = navigationDelegate
        }
    }
}
