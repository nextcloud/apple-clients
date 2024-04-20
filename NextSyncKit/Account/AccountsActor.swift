//
//  AccountsController.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftData
import OSLog

@ModelActor
public actor AccountsActor {
    private let logger = Logger(subsystem: Logger.subsystem, category: "accounts-actor")

    public var anyAccountsConfigured: Bool {
        let accountPredicate = FetchDescriptor<AccountModel>()
        return (try? modelContext.fetchCount(accountPredicate) > 0) ?? false
    }

    public func addAccount(_ accountModel: AccountModel) {
        modelContext.insert(accountModel)
        do {
            try modelContext.save()
            logger.debug("Saved account \(accountModel.description)")
        } catch {
            logger.error("Error saving account: \(error), account: \(accountModel.description)")
        }
    }
}
