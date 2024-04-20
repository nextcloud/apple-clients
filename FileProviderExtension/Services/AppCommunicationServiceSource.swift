//
//  AppCommunicationServiceSource.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation
import NextSyncKit

class AppCommunicationServiceSource: AppCommunicationService {
    let domainIdentifier: NSFileProviderDomainIdentifier
    let authenticationHandler: (_ serverUrl: URL, _ username: String, _ password: String) -> Void

    init(
        domainIdentifier: NSFileProviderDomainIdentifier,
        authenticationHandler: @escaping (_: URL, _: String, _: String) -> Void
    ) {
        self.domainIdentifier = domainIdentifier
        self.authenticationHandler = authenticationHandler
    }

    func domainIdentifierString() async -> String {
        domainIdentifier.rawValue
    }
    
    func authenticate(serverUrl: URL, username: String, password: String) {
        authenticationHandler(serverUrl, username, password)
    }
}
