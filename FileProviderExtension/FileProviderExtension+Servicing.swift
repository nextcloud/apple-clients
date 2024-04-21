//
//  FileProviderExtension+Servicing.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation

extension FileProviderExtension: NSFileProviderServicing {
    func supportedServiceSources(
        for itemIdentifier: NSFileProviderItemIdentifier,
        completionHandler: @escaping ([any NSFileProviderServiceSource]?, (any Error)?) -> Void
    ) -> Progress {
        let appCommunicationService = AppCommunicationServiceSource(
            domainIdentifier: domain.identifier,
            authenticationHandler: { [weak self] serverUrl, username, password in
                self?.authenticate(serverUrl: serverUrl, username: username, password: password)
            }
        )
        completionHandler([], nil)
        return Progress()
    }

    private func authenticate(serverUrl: URL, username: String, password: String) {
        let nkc = ncKit.nkCommonInstance
        let serverString = serverUrl.absoluteString
        guard nkc.urlBase != serverString || nkc.user != username || nkc.password != password else {
            return
        }

        ncKit.setup(user: username, userId: username, password: password, urlBase: serverString)

        guard let manager = NSFileProviderManager(for: domain) else {
            self.logger.error("Could not get manager for domain \(self.domain.rawIdentifier)")
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
