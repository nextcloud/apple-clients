//
//  AccountModel.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftData

@Model
public final class AccountModel {
    public var serverUrl: URL
    public var displayname: String
    public var username: String
    public var id: String
    @Attribute(.allowsCloudEncryption) public var password: String
    public var domainIdentifier: String?

    @Transient public var description: String {
        """
        AccountModel
        serverUrl: \(serverUrl),
        displayname: \(displayname),
        username: \(username),
        id: \(id),
        domainIdentifier: \(domainIdentifier ?? "NONE"),
        password: \(password.isEmpty ? "EMPTY" : "NON-EMPTY")
        """
    }

    public init(
        serverUrl: URL,
        displayname: String = "",
        username: String,
        id: String,
        password: String,
        domainIdentifier: String? = nil
    ) {
        self.serverUrl = serverUrl
        self.displayname = displayname
        self.username = username
        self.id = id
        self.password = password
        self.domainIdentifier = domainIdentifier
    }
}
