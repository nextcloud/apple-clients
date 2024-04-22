//
//  FileProviderExtension.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 20/4/24.
//

import FileProvider
import NextcloudFileProviderKit
import NextcloudKit
import NextSyncKit
import OSLog
import SwiftData

class FileProviderExtension:
    NSObject, NSFileProviderReplicatedExtension, NSFileProviderEnumerating
{
    let domain: NSFileProviderDomain
    let ncKit = NextcloudKit()
    private let logger = Logger(subsystem: Logger.subsystem, category: "file-provider-extension")

    var account: Account?

    required init(domain: NSFileProviderDomain) {
        // The containing application must create a domain using
        // `NSFileProviderManager.add(_:, completionHandler:)`. 
        // The system will then launch the application extension process, call
        // `FileProviderExtension.init(domain:)` to instantiate the extension for that domain, and
        // call methods on the instance.
        logger.info("Instantiating file provider extension for domain: \(domain.rawIdentifier)")
        self.domain = domain
        super.init()
        retrieveAuthentication()
    }
    
    func invalidate() {
        logger.info("Invalidating file provider extension for domain \(self.domain.rawIdentifier)")
    }

    func retrieveAuthentication() {
        let domainIdRaw = domain.rawIdentifier
        do {
            let modelContainer = try ModelContainer(for: AccountModel.self)
            let modelContext = ModelContext(modelContainer)
            let fetchDescriptor = FetchDescriptor<AccountModel>(
                predicate: #Predicate { $0.domainIdentifier == domainIdRaw }
            )
            let match = try modelContext.fetch(fetchDescriptor).first!

            account = Account(
                user: match.username,
                serverUrl: match.serverUrl.absoluteString,
                password: match.password
            )
            
            ncKit.setup(
                user: match.username,
                userId: match.username,
                password: match.password,
                urlBase: match.serverUrl.absoluteString
            )
        } catch let error {
            logger.error("Unable to self authenticate \(self.domain.rawIdentifier): \(error)")
        }
    }

    func item(
        for identifier: NSFileProviderItemIdentifier,
        request: NSFileProviderRequest,
        completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void
    ) -> Progress {
        // resolve the given identifier to a record in the model
        let progress = Progress(totalUnitCount: 1)
        if let item = Item.storedItem(identifier: identifier, usingKit: ncKit) {
            completionHandler(item, nil)
        } else {
            logger.error("Not providing item \(identifier.rawValue), not found")
            completionHandler(nil, NSFileProviderError(.noSuchItem))
        }
        progress.completedUnitCount = progress.totalUnitCount
        return progress
    }
    
    func fetchContents(
        for itemIdentifier: NSFileProviderItemIdentifier,
        version requestedVersion: NSFileProviderItemVersion?,
        request: NSFileProviderRequest,
        completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void)
    -> Progress {
        // Fetching of the contents for the itemIdentifier at the specified version
        let progress = Progress()
        guard let account else {
            logger.error("Not fetching contents of \(itemIdentifier.rawValue), not authenticated")
            completionHandler(nil, nil, NSFileProviderError(.notAuthenticated))
            return progress
        }

        guard let item = Item.storedItem(identifier: itemIdentifier, usingKit: ncKit) else {
            logger.error("Not fetching contents of \(itemIdentifier.rawValue), item not found")
            completionHandler(nil, nil, NSFileProviderError(.noSuchItem))
            return progress
        }

        Task {
            let (url, item, error) = await item.fetchContents(domain: domain, progress: progress)
            completionHandler(url, item, error)
        }
        return progress
    }

    func createItem(
        basedOn itemTemplate: NSFileProviderItem,
        fields: NSFileProviderItemFields,
        contents url: URL?,
        options: NSFileProviderCreateItemOptions = [],
        request: NSFileProviderRequest,
        completionHandler: @escaping (
            NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?
        ) -> Void
    ) -> Progress {
        // A new item was created on disk, process the item's creation
        let progress = Progress()
        guard let account else {
            logger.error("Not creating item \(itemTemplate.filename), not authenticated")
            completionHandler(itemTemplate, [], false, NSFileProviderError(.notAuthenticated))
            return progress
        }

        Task {
            let (item, error) = await Item.create(
                basedOn: itemTemplate,
                contents: url,
                ncKit: ncKit,
                ncAccount: account,
                progress: progress
            ) // Returns item OR the error as non-nil
            completionHandler(item, [], false, error)
        }
        return progress
    }
    
    func modifyItem(
        _ item: NSFileProviderItem,
        baseVersion version: NSFileProviderItemVersion,
        changedFields: NSFileProviderItemFields,
        contents newContents: URL?,
        options: NSFileProviderModifyItemOptions = [],
        request: NSFileProviderRequest,
        completionHandler: @escaping (
            NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?
        ) -> Void
    ) -> Progress {
        // An item was modified on disk, process the item's modification
        let progress = Progress()
        guard let account else {
            logger.error("Not modifying item \(item.filename), not authenticated")
            completionHandler(nil, [], false, NSFileProviderError(.notAuthenticated))
            return progress
        }

        let itemIdentifier = item.itemIdentifier
        guard let storedItem = Item.storedItem(identifier: itemIdentifier, usingKit: ncKit) else {
            logger.error("Not modifying item \(item.filename), not found")
            completionHandler(nil, [], false, NSFileProviderError(.noSuchItem))
            return progress
        }

        Task {
            let (modifiedItem, error) = await storedItem.modify(
                itemTarget: item,
                baseVersion: version,
                changedFields: changedFields,
                contents: newContents,
                options: options,
                request: request,
                ncAccount: account,
                domain: domain,
                progress: progress
            )
            completionHandler(modifiedItem, [], false, error)
        }
        return progress
    }
    
    func deleteItem(
        identifier: NSFileProviderItemIdentifier,
        baseVersion version: NSFileProviderItemVersion,
        options: NSFileProviderDeleteItemOptions = [],
        request: NSFileProviderRequest,
        completionHandler: @escaping (Error?) -> Void
    ) -> Progress {
        // An item was deleted on disk, process the item's deletion
        let progress = Progress(totalUnitCount: 1)
        guard let item = Item.storedItem(identifier: identifier, usingKit: ncKit) else {
            logger.error("Not modifying item \(identifier.rawValue), not found")
            completionHandler(NSFileProviderError(.noSuchItem))
            return progress
        }

        Task {
            let error = await item.delete()
            progress.completedUnitCount = progress.totalUnitCount
            completionHandler(error)
        }
        return progress
    }
    
    func enumerator(
        for containerItemIdentifier: NSFileProviderItemIdentifier,
        request: NSFileProviderRequest
    ) throws -> NSFileProviderEnumerator {
        guard let account else { throw NSFileProviderError(.notAuthenticated) }
        return Enumerator(
            enumeratedItemIdentifier: containerItemIdentifier, ncAccount: account, ncKit: ncKit
        )
    }

    func materializedItemsDidChange() async {
        guard let account else {
            logger.error(
                """
                Not cleaning stale local file metadatas for \(self.domain.rawIdentifier):
                account not set up.
                """
            )
            return
        }

        guard let manager = NSFileProviderManager(for: domain) else {
            logger.error(
                "Could not get file provider manager for domain: \(self.domain.rawIdentifier)"
            )
            return
        }

        let materialisedEnumerator = manager.enumeratorForMaterializedItems()
        await withCheckedContinuation { continuation in
            let materialisedObserver = MaterialisedEnumerationObserver(
                ncKitAccount: account.ncKitAccount // TODO: Just make async in NCFPK
            ) { _ in continuation.resume() }
            let startPage = NSFileProviderPage(NSFileProviderPage.initialPageSortedByName as Data)
            materialisedEnumerator.enumerateItems(for: materialisedObserver, startingAt: startPage)
        }
    }
}
