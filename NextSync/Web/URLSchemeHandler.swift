//
//  URLSchemeHandler.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import SwiftData

fileprivate let internalScheme = "nc"
fileprivate let internalSchemePrefix = internalScheme + "://"

class URLSchemeHandler {
    static let scheme = internalScheme
    private static let schemePrefix = internalSchemePrefix
    private static let loginPrefix = internalSchemePrefix + "login/"
    private static let keyValuePairSeparator = "&"
    private static let keyValueSeparator = ":"

    static func handle(url: URL, container: ModelContainer) {
        guard url.scheme == Self.scheme else { return }

        let urlString = url.absoluteString
        if urlString.hasPrefix(loginPrefix) {
            Self.handleLogin(url: url, container: container)
        }
    }

    private static func handleLogin(url: URL, container: ModelContainer) {
        let loginDetails = url.absoluteString.trimmingPrefix(Self.loginPrefix)
        let keyValuePairs = loginDetails.split(separator: Self.keyValuePairSeparator)
        guard keyValuePairs.count >= 3 else {
            fatalError(
                """
                Key-value pair count in login string is lower than expected and cannot contain
                the required information. Cannot proceed with login!
                Login string is: \(loginDetails)
                """
            )
        }

        var server = ""
        var username = ""
        var password = ""

        for kvPair in keyValuePairs {
            let separatedPair = kvPair.split(separator: Self.keyValueSeparator, maxSplits: 1)
            let key = separatedPair.first ?? ""
            let value = String(separatedPair.last ?? "")

            if key.contains("server") {
                server = value
            } else if key.contains("user") {
                username = value
            } else if key.contains("password") {
                password = value
            }
        }
        print(server, username, password)

        guard !server.isEmpty, !username.isEmpty, !password.isEmpty else {
            fatalError(
                """
                Parsed login url string did not provide expected values!
                server: \(server)
                user: \(username)
                password: \(password.isEmpty ? "EMPTY" : "NON-EMPTY")
                """
            )
        }

        guard let serverUrl = URL(string: server) else {
            fatalError("Could not generate url for server url string \(server)!")
            return
        }

        let account = AccountModel(serverUrl: serverUrl, username: username, password: password)
        let accountsActor = AccountsActor(modelContainer: container)
        Task { await accountsActor.addAccount(account) }
    }
}
