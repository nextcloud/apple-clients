//
//  AccountsController.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import Foundation
import SwiftData

@ModelActor
actor AccountsActor {
    var anyAccountsConfigured: Bool {
        let accountPredicate = FetchDescriptor<AccountModel>()
        return (try? modelContext.fetchCount(accountPredicate) > 0) ?? false
    }

    func addAccount(_ accountModel: AccountModel) {
        modelContext.insert(accountModel)
        do {
            try modelContext.save()
            debugPrint("Saved account \(accountModel.description)")
        } catch {
            fatalError("Error saving account: \(error), account: \(accountModel.description)")
        }
    }
}
