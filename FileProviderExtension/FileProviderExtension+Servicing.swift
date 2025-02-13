//
//  FileProviderExtension+Servicing.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation
import NextcloudFileProviderKit
import OSLog

fileprivate let logger = Logger(subsystem: Logger.subsystem, category: "file-provider-extension")

extension FileProviderExtension: NSFileProviderServicing {

    func supportedServiceSources(
        for itemIdentifier: NSFileProviderItemIdentifier,
        completionHandler: @escaping ([any NSFileProviderServiceSource]?, (any Error)?) -> Void
    ) -> Progress {
        logger.info("Services requested on extension handling \(self.domain.rawIdentifier)")
        
        let appCommunicationService = AppCommunicationServiceSource(
            domainIdentifier: domain.identifier,
            authenticationHandler: { [weak self] serverUrl, username, userId, password in
                self?.authenticate(
                    serverUrl: serverUrl, username: username, userId: userId, password: password
                )
            }
        )
        completionHandler([appCommunicationService], nil)

        let progress = Progress()
        progress.cancellationHandler = {
            completionHandler(nil, NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
        }
        return progress
    }

    private func authenticate(serverUrl: URL, username: String, userId: String, password: String) {
       account = Account(
            user: username, id: userId, serverUrl: serverUrl.absoluteString, password: password
        )

        guard let manager = NSFileProviderManager(for: domain) else {
            logger.error("Could not get manager for domain \(self.domain.rawIdentifier)")
            return
        }
        let resolvedError = NSFileProviderError(.notAuthenticated)

        Task {
            do {
                try await manager.signalErrorResolved(resolvedError)
            } catch let error {
                logger.error("Error signalling authentication error resolved: \(error)")
            }
        }
    }
}
