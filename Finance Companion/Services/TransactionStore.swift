//
//  TransactionStore.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import Observation
import SwiftData

// MARK: - TransactionStore

/// Single source of truth for all transactions in the app.
/// Backed by SwiftData — every mutation is persisted automatically.
/// Both `HomeViewModel` and `TransactionsViewModel` observe this store,
/// ensuring mutations on one screen are immediately reflected on the other.
@Observable
final class TransactionStore {

    // MARK: - Singleton

    static let shared = TransactionStore()

    // MARK: - State

    private(set) var transactions: [Transaction] = []

    // MARK: - Private

    private var context: ModelContext { PersistenceController.shared.modelContext }

    // MARK: - Init

    private init() {
        loadTransactions()
    }

    // MARK: - Fetch

    /// Reloads all transactions from SwiftData, sorted newest-first.
    private func loadTransactions() {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        transactions = (try? context.fetch(descriptor)) ?? []
        BudgetStore.shared.recalculateSpending(from: transactions)
    }

    // MARK: - CRUD

    /// Inserts a new transaction and persists it.
    func add(_ transaction: Transaction) {
        context.insert(transaction)
        save()
        loadTransactions()
    }

    /// Deletes the transaction matching the given ID.
    func delete(id: UUID) {
        guard let target = transactions.first(where: { $0.id == id }) else { return }
        context.delete(target)
        save()
        loadTransactions()
    }

    /// Updates an existing transaction by matching IDs and copying new field values.
    /// The caller passes a temporary Transaction as a value container;
    /// the actual persisted object is mutated in-place.
    func update(_ transaction: Transaction) {
        guard let existing = transactions.first(where: { $0.id == transaction.id }) else { return }
        existing.amount   = transaction.amount
        existing.type     = transaction.type
        existing.category = transaction.category
        existing.date     = transaction.date
        existing.note     = transaction.note
        save()
        loadTransactions()
    }

    // MARK: - Persist

    private func save() {
        do {
            try context.save()
        } catch {
            print("[TransactionStore] Save error: \(error)")
        }
    }
}
