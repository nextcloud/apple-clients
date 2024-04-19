//
//  WebViewRepresentable.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI
import WebKit

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

#if os(iOS) || os(macOS)
public struct WebView: WebViewRepresentable {
    private let url: URL?
    private let configuration: WKWebViewConfiguration
    private let setup: (WKWebView) -> Void

    public init(
        url: URL? = nil,
        configuration: WKWebViewConfiguration = WKWebViewConfiguration(),
        setup: @escaping (WKWebView) -> Void
    ) {
        self.url = url
        self.configuration = configuration
        self.setup = setup
    }

    #if os(iOS)
    public func makeUIView(context: Context) -> WKWebView {
        makeView()
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif

    #if os(macOS)
    public func makeNSView(context: Context) -> WKWebView {
        makeView()
    }

    public func updateNSView(_ view: WKWebView, context: Context) {}
    #endif

    func makeView() -> WKWebView {
        let view = WKWebView(frame: .null, configuration: configuration)
        setup(view)
        tryLoad(url, into: view)
        return view
    }

    func tryLoad(_ url: URL?, into view: WKWebView) {
        guard let url = url else { return }
        view.load(URLRequest(url: url))
    }
}
#endif
