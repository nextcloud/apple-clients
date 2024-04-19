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
typealias InternalViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias InternalViewRepresentable = NSViewRepresentable
#endif

#if os(iOS) || os(macOS)
public struct WebViewRepresentable: InternalViewRepresentable {
    private let url: URL?
    private let request: URLRequest?
    private let configuration: WKWebViewConfiguration
    private let setup: (WKWebView) -> Void

    public init(
        url: URL? = nil,
        request: URLRequest? = nil,
        configuration: WKWebViewConfiguration = WKWebViewConfiguration(),
        setup: @escaping (WKWebView) -> Void
    ) {
        self.url = url
        self.request = request
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
        tryLoad(into: view)
        return view
    }

    private func tryLoad(into view: WKWebView) {
        guard url != nil || request != nil else { return }
        if let request {
            view.load(request)
        } else if let url {
            view.load(URLRequest(url: url))
        }
    }
}
#endif
