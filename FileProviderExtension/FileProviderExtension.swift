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

let AuthenticationTimeouts: [UInt64] = [ // Have progressively longer timeouts to not hammer server
    3_000_000_000, 6_000_000_000, 30_000_000_000, 60_000_000_000, 120_000_000_000, 300_000_000_000
]

class FileProviderExtension:
    NSObject, NSFileProviderReplicatedExtension, NSFileProviderEnumerating, ChangeNotificationInterface
{
    func notifyChange() {
        NSFileProviderManager(for: domain)?.signalEnumerator(for: .workingSet) { error in
            if let error = error {
                self.logger.error(
                    """
                    Could not signal enumerator for \(self.account?.ncKitAccount ?? "", privacy: .public):
                    \(error.localizedDescription, privacy: .public)
                    """
                )
            }
        }
    }
    
    let domain: NSFileProviderDomain
    let ncKit = NextcloudKit.shared
    internal let logger = Logger(subsystem: Logger.subsystem, category: "file-provider-extension")
    private var remoteChangeObserver: RemoteChangeObserver?

    var authenticated = false
    var account: Account? {
        didSet {
            guard let account, account != oldValue else { return }

            authenticated = false

            ncKit.appendSession(
                account: account.ncKitAccount,
                urlBase: account.serverUrl,
                user: account.username,
                userId: account.id,
                password: account.password,
                userAgent: "NextSync",
                nextcloudVersion: 25,
                groupIdentifier: ""
            )

            Task {
                var authAttemptState = AuthenticationAttemptResultState.connectionError // default

                // Retry a few times if we have a connection issue
                for authTimeout in AuthenticationTimeouts {
                    authAttemptState = await ncKit.tryAuthenticationAttempt(account: account)
                    guard authAttemptState == .connectionError else { break }

                    logger.info(
                        """
                        \(account.username, privacy: .public) authentication try timed out.
                            Trying again soon.
                        """
                    )
                    try? await Task.sleep(nanoseconds: authTimeout)
                }

                switch (authAttemptState) {
                case .authenticationError:
                    logger.info(
                        """
                        \(account.username, privacy: .public) authentication failed.
                            Caused by bad creds, stopping.
                        """
                    )
                    return
                case .connectionError:
                    // Despite multiple connection attempts we are still getting connection issues.
                    // Connection error should be provided
                    logger.info(
                        """
                        \(account.username, privacy: .public) authentication try failed.
                            No connection.
                        """
                    )
                    return
                case .success:
                    logger.info(
                    """
                        Authenticated! Nextcloud account set up in File Provider extension.
                            User: \(account.username, privacy: .public)
                            at server: \(account.serverUrl, privacy: .public)
                    """
                    )
                    authenticated = true
                }

                Task { @MainActor in
                    self.account = account
                    remoteChangeObserver = RemoteChangeObserver(
                        account: account,
                        remoteInterface: ncKit,
                        changeNotificationInterface: self,
                        domain: domain
                    )
                    ncKit.setup(delegate: remoteChangeObserver)
                }
            }
        }
    }

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
                id: match.userId,
                serverUrl: match.serverUrl.absoluteString,
                password: match.password
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
        guard let account else {
            logger.error(
                "Unauthenticated, cannot provide item. \(identifier.rawValue, privacy: .public)"
            )
            completionHandler(nil, NSFileProviderError(.notAuthenticated))
            return progress
        }
        if let item = Item.storedItem(
            identifier: identifier, account: account, remoteInterface: ncKit
        ) {
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
        logger.debug(
            "Received fetch contents request for item: \(itemIdentifier.rawValue, privacy: .public)"
        )

        guard requestedVersion == nil else {
            // TODO: Add proper support for file versioning
            logger.error( "Can't return contents for a specific version as this is not supported.")
#if os(macOS)
            completionHandler(nil, nil, NSFileProviderError(.versionNoLongerAvailable))
#endif
            return Progress()
        }

        let progress = Progress()
        guard let account else {
            logger.error("Not fetching contents of \(itemIdentifier.rawValue), not authenticated")
            completionHandler(nil, nil, NSFileProviderError(.notAuthenticated))
            return progress
        }

        guard let item = Item.storedItem(
            identifier: itemIdentifier, account: account, remoteInterface: ncKit
        ) else {
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
                fields: fields,
                contents: url,
                request: request,
                domain: domain,
                account: account,
                remoteInterface: ncKit,
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
        guard let storedItem = Item.storedItem(
            identifier: itemIdentifier, account: account, remoteInterface: ncKit
        ) else {
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
        guard let account else {
            logger.error(
                "Unauthenticated, cannot delete item. \(identifier.rawValue, privacy: .public)"
            )
            completionHandler(NSFileProviderError(.notAuthenticated))
            return progress
        }
        guard let item = Item.storedItem(
            identifier: identifier, account: account, remoteInterface: ncKit
        ) else {
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
        logger.info("Enumerator request for: \(containerItemIdentifier.rawValue, privacy: .public)")
        guard let account else {
            logger.error("Unauthenticated, not proceeding with providing enumerator")
            throw NSFileProviderError(.notAuthenticated)
        }
        return Enumerator(
            enumeratedItemIdentifier: containerItemIdentifier,
            account: account,
            remoteInterface: ncKit
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
