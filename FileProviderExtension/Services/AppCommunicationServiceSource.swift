//
//  AppCommunicationServiceSource.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation
import NextSyncKit
import OSLog

class AppCommunicationServiceSource:
    NSObject, AppCommunicationService, NSFileProviderServiceSource, NSXPCListenerDelegate
{
    let serviceName = AppCommunicationServiceName
    let domainIdentifier: NSFileProviderDomainIdentifier
    let authenticationHandler: (_ serverUrl: URL, _ username: String, _ password: String) -> Void
    let listener = NSXPCListener.anonymous()
    private let logger = Logger(subsystem: Logger.subsystem, category: "app-comm-service-source")

    init(
        domainIdentifier: NSFileProviderDomainIdentifier,
        authenticationHandler: @escaping (_: URL, _: String, _: String) -> Void
    ) {
        self.domainIdentifier = domainIdentifier
        self.authenticationHandler = authenticationHandler
    }

    // MARK: - AppCommunicationService conformance
    func domainIdentifierString() async -> String {
        domainIdentifier.rawValue
    }
    
    func authenticate(serverUrl: URL, username: String, password: String) {
        logger.info("Received authentication info: \(serverUrl), \(username)")
        authenticationHandler(serverUrl, username, password)
    }

    // MARK: - NSFileProviderServiceSource conformance
    func makeListenerEndpoint() throws -> NSXPCListenerEndpoint {
        listener.delegate = self
        listener.resume()
        return listener.endpoint
    }

    // MARK: - NSXPCListenerDelegate conformance
    func listener(
        _ listener: NSXPCListener,
        shouldAcceptNewConnection newConnection: NSXPCConnection
    ) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: AppCommunicationService.self)
        newConnection.exportedObject = self
        newConnection.resume()
        return true
    }
}
