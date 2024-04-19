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
        serverUrl = URL(string: serverString)
    }
}
