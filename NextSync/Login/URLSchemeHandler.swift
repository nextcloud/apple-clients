//
//  URLSchemeHandler.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation

fileprivate let internalScheme = "nc"
fileprivate let internalSchemePrefix = internalScheme + "://"

class URLSchemeHandler {
    static let scheme = internalScheme
    static func handle(url: URL) {
        guard url.scheme == Self.scheme else { return }
    }
}
