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
import OSLog

class FileProviderController: ObservableObject {
    private var logger = Logger(subsystem: Logger.subsystem, category: "fileprovider-controller")

    init(modelContainer: ModelContainer) {
        let modelContext = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<AccountModel>()
        let accounts = try? modelContext.fetch(fetchDescriptor)
        accounts?.forEach { account in Task { await createDomain(account: account) } }
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
            logger.error("Could not check if domain \(domain.identifier.rawValue) exists: \(error)")
            return false
        }
    }

    func createDomain(account: AccountModel) async {
        let domain = domain(account: account)
        guard await !domainExists(domain) else { return }
        do {
            try await NSFileProviderManager.add(domain)
        } catch let error {
            logger.error("Could not add domain for \(domain.identifier.rawValue): \(error)")
        }
    }
}
