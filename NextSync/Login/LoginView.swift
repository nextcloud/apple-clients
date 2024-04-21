//
//  LoginServerView.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    enum LoginType {
        case webFlow
    }

    @State var serverString = ""
    @State var serverUrl: URL?
    @State private var webNavigationDelegate = LoginWebNavigationDelegate()
    @State private var path = [LoginType]()

    private static let httpPrefix = "http://"
    private static let httpsPrefix = "https://"
    private static let loginFlowSuffix = "/index.php/login/flow"

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Welcome to NextSync!")
                TextField("Nextcloud server location", text: $serverString)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    #if !os(macOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .onChange(of: serverString) { updateServerUrl() }
                    .onSubmit { path = [.webFlow] }
                NavigationLink("Go", value: LoginType.webFlow)
            }
            .navigationDestination(for: LoginType.self) { loginType in
                if let serverUrl, loginType == .webFlow {
                    LoginWebView(serverUrl: serverUrl, navigationDelegate: webNavigationDelegate)
                        .onChange(of: webNavigationDelegate.finished) {
                            if webNavigationDelegate.finished {
                                path.removeAll { $0 == .webFlow }
                            }
                        }
                }
            }
            .padding()
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
