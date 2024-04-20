//
//  AccountPicker.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import NextSyncKit
import SwiftData
import SwiftUI

struct AccountPicker: View {
    @Query var accounts: [AccountModel] = []
    @Binding var selection: AccountModel?

    var body: some View {
        Picker("Account", systemImage: "person", selection: $selection) {
            ForEach(accounts) { account in
                let name = account.displayname.isEmpty ? account.username : account.displayname
                let display = "\(name) (\(account.serverUrl.host() ?? ""))"
                Text(display).tag(Optional(account))
            }
        }
    }
}
