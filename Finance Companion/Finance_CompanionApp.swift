//
//  Finance_CompanionApp.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI
import SwiftData

@main
struct Finance_CompanionApp: App {

    init() {
        // 1. Seed mock data into SwiftData exactly once (guarded by UserDefaults flag).
        //    This must run before any view touches TransactionStore or BudgetStore.
        MockDataService.seedIfNeeded(context: PersistenceController.shared.modelContext)

        // 2. Warm up the stores so they load persisted data before the first frame renders.
        _ = TransactionStore.shared
        _ = BudgetStore.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
