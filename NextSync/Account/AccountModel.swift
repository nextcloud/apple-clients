//
//  AccountModel.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftData

@Model
final class AccountModel {
    var serverUrl: URL
    var displayname: String
    var username: String
    @Attribute(.allowsCloudEncryption) var password: String

    init(
        serverUrl: URL,
        displayname: String = "",
        username: String,
        password: String
    ) {
        self.serverUrl = serverUrl
        self.displayname = displayname
        self.username = username
        self.password = password
    }
}
