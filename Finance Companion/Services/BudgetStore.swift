//
//  BudgetStore.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import Observation
import SwiftData

// MARK: - BudgetStore

/// Single source of truth for all budgets.
/// Category budgets are persisted via SwiftData.
/// `totalBudget` (a single scalar) is persisted via UserDefaults for simplicity.
@Observable
final class BudgetStore {

    // MARK: - Singleton

    static let shared = BudgetStore()

    // MARK: - State

    /// User-entered total monthly budget.
    /// Stored in UserDefaults so it survives app restarts without a dedicated model.
    private(set) var totalBudget: Double = UserDefaults.standard.double(forKey: "totalMonthlyBudget")

    /// Individual category budgets — loaded from SwiftData.
    private(set) var budgets: [Budget] = []

    // MARK: - Private

    private var context: ModelContext { PersistenceController.shared.modelContext }

    // MARK: - Init

    private init() {
        loadBudgets()
    }

    // MARK: - Fetch

    private func loadBudgets() {
        let descriptor = FetchDescriptor<Budget>()
        budgets = (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Total Budget Management

    /// Whether the user has set a total budget.
    var hasTotalBudget: Bool { totalBudget > 0 }

    /// Sets the total monthly budget and persists it.
    /// - If `newValue` is **higher**: category budgets remain unchanged.
    /// - If `newValue` is **lower**: all category budgets are reset to zero.
    /// Caller is responsible for confirming the destructive case via alert before calling this.
    func setTotalBudget(_ newValue: Double) {
        let oldValue = totalBudget
        totalBudget = max(newValue, 0)
        UserDefaults.standard.set(totalBudget, forKey: "totalMonthlyBudget")

        if totalBudget < oldValue {
            resetAllBudgets()
        }
    }

    /// Deletes all category budgets from SwiftData.
    private func resetAllBudgets() {
        for budget in budgets {
            context.delete(budget)
        }
        save()
        loadBudgets()
    }

    // MARK: - CRUD

    /// Adds a new budget for a category. Prevents duplicates and clamps to `maxAllowed`.
    func add(category: TransactionCategory, limit: Double, maxAllowed: Double) {
        guard !budgets.contains(where: { $0.category == category }) else { return }
        let clampedLimit = min(limit, maxAllowed)
        guard clampedLimit > 0 else { return }
        let budget = Budget(category: category, limit: clampedLimit)
        context.insert(budget)
        save()
        loadBudgets()
    }

    /// Updates the limit for an existing budget. Clamps to `maxAllowed`.
    func update(id: UUID, newLimit: Double, maxAllowed: Double) {
        guard let budget = budgets.first(where: { $0.id == id }) else { return }
        let clampedLimit = min(newLimit, maxAllowed)
        guard clampedLimit > 0 else { return }
        budget.limit = clampedLimit
        save()
        loadBudgets()
    }

    /// Removes a budget by ID.
    func delete(id: UUID) {
        guard let budget = budgets.first(where: { $0.id == id }) else { return }
        context.delete(budget)
        save()
        loadBudgets()
    }

    /// Looks up the budget for a specific category.
    func budget(for category: TransactionCategory) -> Budget? {
        budgets.first { $0.category == category }
    }

    // MARK: - Spending Recalculation

    /// Recomputes `spent` for every budget using current-month transactions.
    /// `spent` is @Transient — it is never persisted, only held in memory.
    /// Call this whenever transactions change.
    func recalculateSpending(from transactions: [Transaction]) {
        let calendar = Calendar.current
        let now = Date.now
        let currentMonth = calendar.component(.month, from: now)
        let currentYear  = calendar.component(.year,  from: now)

        let monthExpenses = transactions.filter { tx in
            tx.type == .expense &&
            calendar.component(.month, from: tx.date) == currentMonth &&
            calendar.component(.year,  from: tx.date) == currentYear
        }

        for budget in budgets {
            budget.spent = monthExpenses
                .filter { $0.category == budget.category }
                .reduce(0) { $0 + $1.amount }
        }
    }

    // MARK: - Allocation Helpers

    /// Total of all category budget limits.
    var totalAllocated: Double {
        budgets.reduce(0) { $0 + $1.limit }
    }

    // MARK: - Persist

    private func save() {
        do {
            try context.save()
        } catch {
            print("[BudgetStore] Save error: \(error)")
        }
    }
}
