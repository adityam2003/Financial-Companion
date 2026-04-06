//
//  TransactionsViewModel.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import Observation

// MARK: - Transaction Filter

/// Filter options for the Transactions list.
enum TransactionFilter: String, CaseIterable, Identifiable {
    case all     = "All"
    case income  = "Income"
    case expense = "Expense"

    var id: String { rawValue }
}

// MARK: - Transaction Group

/// A date-based group of transactions for sectioned display.
struct TransactionGroup: Identifiable {
    let id: String          // group title doubles as a stable ID
    let title: String       // "Today", "Yesterday", "Earlier"
    let transactions: [Transaction]
}

// MARK: - TransactionsViewModel

/// Drives the Transactions screen.
/// Reads from the shared `TransactionStore` so all mutations
/// are instantly visible on every screen that observes the store.
@Observable
final class TransactionsViewModel {

    // MARK: - Shared Store

    private let store = TransactionStore.shared

    // MARK: - UI State

    var searchText: String = ""
    var selectedFilter: TransactionFilter = .all
    var showingAddSheet: Bool = false
    var editingTransaction: Transaction? = nil

    // MARK: - Filtered Transactions

    /// Applies the active search text and type filter.
    var filteredTransactions: [Transaction] {
        var result = store.transactions

        // Type filter
        switch selectedFilter {
        case .all:     break
        case .income:  result = result.filter { $0.type == .income }
        case .expense: result = result.filter { $0.type == .expense }
        }

        // Search filter (matches note or category name)
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.note.lowercased().contains(query) ||
                $0.category.rawValue.lowercased().contains(query)
            }
        }

        return result
    }

    // MARK: - Grouped Transactions

    /// Groups filtered transactions into "Today", "Yesterday", and "Earlier".
    var groupedTransactions: [TransactionGroup] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var todayItems: [Transaction] = []
        var yesterdayItems: [Transaction] = []
        var earlierItems: [Transaction] = []

        for transaction in filteredTransactions {
            let txDay = calendar.startOfDay(for: transaction.date)
            if txDay == today {
                todayItems.append(transaction)
            } else if txDay == yesterday {
                yesterdayItems.append(transaction)
            } else {
                earlierItems.append(transaction)
            }
        }

        var groups: [TransactionGroup] = []
        if !todayItems.isEmpty {
            groups.append(TransactionGroup(id: "Today", title: "Today", transactions: todayItems))
        }
        if !yesterdayItems.isEmpty {
            groups.append(TransactionGroup(id: "Yesterday", title: "Yesterday", transactions: yesterdayItems))
        }
        if !earlierItems.isEmpty {
            groups.append(TransactionGroup(id: "Earlier", title: "Earlier", transactions: earlierItems))
        }

        return groups
    }

    // MARK: - CRUD (delegated to store)

    func addTransaction(
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        note: String,
        date: Date
    ) {
        let transaction = Transaction(
            amount: amount,
            type: type,
            category: category,
            date: date,
            note: note
        )
        store.add(transaction)
    }

    func deleteTransaction(_ transaction: Transaction) {
        store.delete(id: transaction.id)
    }

    func updateTransaction(
        id: UUID,
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        note: String,
        date: Date
    ) {
        let updated = Transaction(
            id: id,
            amount: amount,
            type: type,
            category: category,
            date: date,
            note: note
        )
        store.update(updated)
    }
}
