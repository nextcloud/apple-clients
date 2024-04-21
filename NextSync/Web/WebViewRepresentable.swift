//
//  WebViewRepresentable.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI
import WebKit

#if os(macOS)
typealias InternalViewRepresentable = NSViewRepresentable
#else
typealias InternalViewRepresentable = UIViewRepresentable
#endif

public struct WebViewRepresentable: InternalViewRepresentable {
    @Observable public class WebViewStateBridge {
        var isLoading: Bool = true
        var estimatedProgress: Double = 0
        public init() {}
    }

    private let url: URL?
    private let request: URLRequest?
    private let configuration: WKWebViewConfiguration
    private let setup: (WKWebView) -> Void
    private let bridge: WebViewStateBridge

    public init(
        bridge: WebViewStateBridge = WebViewStateBridge(),
        url: URL? = nil,
        request: URLRequest? = nil,
        configuration: WKWebViewConfiguration = WKWebViewConfiguration(),
        setup: @escaping (WKWebView) -> Void
    ) {
        self.bridge = bridge
        self.url = url
        self.request = request
        self.configuration = configuration
        self.setup = setup
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator: NSObject {
        var loadObservation: NSKeyValueObservation?
        var progressObservation: NSKeyValueObservation?
    }

    #if os(macOS)
    public func makeNSView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    public func updateNSView(_ view: WKWebView, context: Context) {}
    #else
    public func makeUIView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif


    func makeView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .null, configuration: configuration)
        context.coordinator.loadObservation = view.observe(\.isLoading) { view, value in
            self.bridge.isLoading = view.isLoading
        }
        context.coordinator.progressObservation = view.observe(\.estimatedProgress) { view, value in
            self.bridge.estimatedProgress = view.estimatedProgress
        }
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
