//
//  LoginServerView.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State var serverString = ""
    @State var serverUrl: URL? 

    private static let httpPrefix = "http://"
    private static let httpsPrefix = "https://"
    private static let loginFlowSuffix = "/index.php/login/flow"

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to NextSync!")
                TextField("Nextcloud server location", text: $serverString)
                    .onChange(of: serverString) { updateServerUrl() }
                NavigationLink {
                    LoginWebView(serverUrl: $serverUrl)
                } label: {
                    Label("Go", systemImage: "arrow.right")
                }
            }
        }
    }

    private func updateServerUrl() {
        let sanitisedServerString = Self.sanitiseServerString(serverString) + Self.loginFlowSuffix
        serverUrl = URL(string: sanitisedServerString)
    }

    private static func sanitiseServerString(_ serverString: String) -> String {
        var sanitisedServerString = serverString
        sanitisedServerString.trimPrefix(Self.httpPrefix)
        if !sanitisedServerString.hasPrefix(Self.httpsPrefix) {
            sanitisedServerString = Self.httpsPrefix + sanitisedServerString
        }
        if sanitisedServerString.last == "/" {
            sanitisedServerString.removeLast()
        }
        return sanitisedServerString
    }
}
