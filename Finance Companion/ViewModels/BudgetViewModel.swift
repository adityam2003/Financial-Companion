//
//  BudgetViewModel.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import Observation

// MARK: - BudgetViewModel

/// Drives all budget-related UI: Home section, detail sheet, add flow, and all-budgets list.
/// Reads from both `BudgetStore` and `TransactionStore` to compute spending and enforce allocation limits.
@Observable
final class BudgetViewModel {

    // MARK: - Stores

    private let budgetStore = BudgetStore.shared
    private let transactionStore = TransactionStore.shared

    // MARK: - UI State

    var showingAddBudgetSheet: Bool = false
    var showingAllBudgets: Bool = false
    var showingBudgetDetail: Budget? = nil
    var showingSetTotalBudgetSheet: Bool = false
    var showingBudgetFullAlert: Bool = false

    // MARK: - Computed — Total Budget

    /// The user-entered total monthly budget.
    var totalBudget: Double { budgetStore.totalBudget }

    /// Whether the user has set a total budget yet.
    var hasTotalBudget: Bool { budgetStore.hasTotalBudget }

    // MARK: - Computed — Budgets

    /// Whether the user has any category budgets at all.
    var hasBudgets: Bool { !budgetStore.budgets.isEmpty }

    /// Top 5 budgets sorted by progress (most-used first) for the Home section.
    var topBudgets: [Budget] {
        Array(
            budgetStore.budgets
                .sorted { $0.progress > $1.progress }
                .prefix(5)
        )
    }

    /// All budgets for the View All sheet.
    var allBudgets: [Budget] { budgetStore.budgets }

    // MARK: - Computed — Allocation

    /// Sum of all existing category budget limits.
    var totalAllocated: Double { budgetStore.totalAllocated }

    /// How much the user can still assign to new/edited category budgets.
    var remainingAllocatable: Double {
        max(totalBudget - totalAllocated, 0)
    }

    /// Whether the budget is fully allocated (no room for new category budgets).
    var isBudgetFull: Bool {
        remainingAllocatable <= 0
    }

    /// Maximum allowed for a new category budget.
    var maxAllowedForNew: Double { remainingAllocatable }

    /// Maximum allowed when editing an existing category budget
    /// (remaining + that budget's current limit — because it's being replaced).
    func maxAllowedForEdit(_ budget: Budget) -> Double {
        remainingAllocatable + budget.limit
    }

    /// Categories that don't have a budget yet (for the add flow picker).
    var availableCategories: [TransactionCategory] {
        let budgeted = Set(budgetStore.budgets.map(\.category))
        // Only show expense-type categories (exclude salary, freelance)
        return TransactionCategory.allCases.filter { category in
            !budgeted.contains(category) &&
            category != .salary &&
            category != .freelance
        }
    }

    // MARK: - Total Budget Management

    /// Directly sets the total budget. The store handles reset logic internally
    /// (lowering wipes all category budgets).
    /// The destructive alert is handled by `SetTotalBudgetSheet` itself.
    func setTotalBudget(_ newValue: Double) {
        budgetStore.setTotalBudget(newValue)
    }

    // MARK: - Add Budget with Full Check

    /// Attempts to open the add budget sheet.
    /// If budget is fully allocated or no categories available, shows an alert instead.
    func requestAddBudget() {
        if isBudgetFull || availableCategories.isEmpty {
            showingBudgetFullAlert = true
        } else {
            showingAddBudgetSheet = true
        }
    }

    // MARK: - CRUD (Category Budgets)

    func addBudget(category: TransactionCategory, limit: Double) {
        budgetStore.add(category: category, limit: limit, maxAllowed: maxAllowedForNew)
        recalculate()
    }

    func updateBudget(_ budget: Budget, newLimit: Double) {
        budgetStore.update(
            id: budget.id,
            newLimit: newLimit,
            maxAllowed: maxAllowedForEdit(budget)
        )
        recalculate()
    }

    func deleteBudget(_ budget: Budget) {
        budgetStore.delete(id: budget.id)
    }

    // MARK: - Recalculation

    /// Recomputes spending from transactions.
    /// Call when transactions change or on appear.
    func recalculate() {
        budgetStore.recalculateSpending(from: transactionStore.transactions)
    }

    // MARK: - Insight for AddTransactionSheet

    /// Returns a contextual budget message for a given category, or nil if no budget exists.
    func budgetInsight(for category: TransactionCategory) -> String? {
        guard let budget = budgetStore.budget(for: category) else { return nil }

        let percent = Int(budget.progress * 100)

        switch budget.status {
        case .safe:
            return "\(category.rawValue) budget: \(budget.spent.currencyFormatted) / \(budget.limit.currencyFormatted) (\(percent)%)"
        case .warning:
            return "You're close to your \(category.rawValue) budget ⚠️ (\(percent)%)"
        case .exceeded:
            return "You've exceeded your \(category.rawValue) budget 🚨"
        }
    }
}
