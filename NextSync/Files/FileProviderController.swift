//
//  FileProviderController.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import SwiftData
import SwiftUI
import Foundation
import FileProvider
import NextSyncKit
import OSLog

class FileProviderController: ObservableObject {
    private enum DomainAuthError: Error {
        case nullService, nullRemoteObject, nonConformingRemoteService
    }
    private var logger = Logger(subsystem: Logger.subsystem, category: "fileprovider-controller")

    init(modelContainer: ModelContainer) {
        let modelContext = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<AccountModel>()
        let accounts = try? modelContext.fetch(fetchDescriptor)

        accounts?.forEach { account in
            Task {
                let domain = domain(account: account)
                await createDomain(domain)
                await authenticateDomain(domain, account: account)
            }
        }
    }

    func domain(account: AccountModel) -> NSFileProviderDomain {
        let domainHostString = account.serverUrl.host!
        let domainId = NSFileProviderDomainIdentifier("\(account.username)@\(domainHostString)")
        let domainDisplay = "\(account.username) (\(domainHostString))"
        return NSFileProviderDomain(identifier: domainId, displayName: domainDisplay)
    }

    func domainExists(_ domain: NSFileProviderDomain) async -> Bool {
        do {
            return try await NSFileProviderManager.domains().contains(domain)
        } catch let error {
            logger.error("Could not check if domain \(domain.rawIdentifier) exists: \(error)")
            return false
        }
    }

    func createDomain(_ domain: NSFileProviderDomain) async {
        guard await !domainExists(domain) else { return }
        do {
            try await NSFileProviderManager.add(domain)
        } catch let error {
            logger.error("Could not add domain for \(domain.rawIdentifier): \(error)")
        }
    }

    func authenticateDomain(_ domain: NSFileProviderDomain, account: AccountModel) async {
        guard let manager = NSFileProviderManager(for: domain) else {
            logger.error("Could not acquire manager for domain: \(domain.rawIdentifier)")
            return
        }

        do {
            guard let service = try await manager.service(
                named: AppCommunicationServiceName, for: .rootContainer
            ) else { throw DomainAuthError.nullService }
            let connection = try await service.fileProviderConnection()
            let logStringPrefix = "AppCommunicationService connection for \(domain.rawIdentifier)"

            connection.remoteObjectInterface = NSXPCInterface(with: AppCommunicationService.self)
            connection.interruptionHandler = { self.logger.debug("\(logStringPrefix) interrupted") }
            connection.invalidationHandler = { self.logger.debug("\(logStringPrefix) invalidated") }
            connection.resume()

            guard let remoteService = connection.remoteObjectInterface else {
                throw DomainAuthError.nullRemoteObject
            }
            guard let appCommService = remoteService as? AppCommunicationService else {
                throw DomainAuthError.nonConformingRemoteService
            }
            
            appCommService.authenticate(
                serverUrl: account.serverUrl, username: account.username, password: account.password
            )
        } catch let error {
            logger.error("Could not authenticate domain \(domain.rawIdentifier): \(error)")
        }
    }
}
