//
//  ContentView.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import NextSyncKit
import SwiftData
import SwiftUI

struct ContentView: View {
    @Query var accounts: [AccountModel]

    var body: some View {
        if accounts.isEmpty {
            LoginView()
        } else {
            MainSplitContentView()
        }
    }
}

#Preview {
    ContentView()
}
