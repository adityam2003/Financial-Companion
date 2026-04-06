//
//  HomeViewModel.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import Foundation
import Observation

// MARK: - HomeViewModel

/// Drives the Home Dashboard screen.
/// Keeps all business logic out of the view layer.
@Observable
final class HomeViewModel {

    // MARK: - Shared Store

    private let store = TransactionStore.shared
    private let budgetStore = BudgetStore.shared

    /// Convenience accessor — always in sync with the shared store.
    var transactions: [Transaction] { store.transactions }

    // MARK: - Published State

    private(set) var weeklySpending: [DailySpending] = []
    private(set) var noSpendStreak: Int = 0
    private(set) var motivationalMessage: String = ""

    // MARK: - Computed Properties

    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    var currentBalance: Double {
        totalIncome - totalExpenses
    }

    // MARK: - Spending Insight

    /// Computes a short insight comparing this week's total spending to last week's.
    /// Returns a motivating, human-readable string.
    var spendingInsight: String {
        let currentTotal = weeklySpending.reduce(0) { $0 + $1.amount }
        let previousTotal = weeklySpending.reduce(0) { $0 + $1.previousAmount }

        guard previousTotal > 0 else { return "First week tracked! 🎯" }

        let change = currentTotal - previousTotal
        let percentChange = abs(change / previousTotal) * 100
        let rounded = Int(percentChange)

        if change > 0 {
            return "Spent \(rounded)% more than last week 📈"
        } else if change < 0 {
            return "Reduced spending by \(rounded)% 👏"
        } else {
            return "Same as last week — stay steady 🎯"
        }
    }

    /// True when this week's spending is lower than or equal to last week's.
    var isSpendingDown: Bool {
        let currentTotal = weeklySpending.reduce(0) { $0 + $1.amount }
        let previousTotal = weeklySpending.reduce(0) { $0 + $1.previousAmount }
        return currentTotal <= previousTotal
    }

    // MARK: - History Check

    /// True when the user has at least 5 days of expense history.
    /// Until then, intensity coloring is disabled — bars stay uniform blue.
    var hasEnoughHistory: Bool {
        let calendar = Calendar.current
        let uniqueExpenseDays = Set(
            transactions
                .filter { $0.type == .expense }
                .map { calendar.startOfDay(for: $0.date) }
        )
        return uniqueExpenseDays.count >= 5
    }

    // MARK: - Streak Message (computed, not hardcoded)

    /// Dynamic motivational message for the streak section.
    var streakMessage: String {
        switch noSpendStreak {
        case 0:     return "Start your streak today!"
        case 1:     return "🔥 1 day streak! Keep it going!"
        case 2...3: return "🔥 \(noSpendStreak) day streak! Building momentum!"
        case 4...6: return "🔥 \(noSpendStreak) day streak! Almost there!"
        default:    return "🔥 \(noSpendStreak) day streak! You're a legend! 🏆"
        }
    }

    // MARK: - Initializer

    init() {
        loadData()
    }

    // MARK: - Data Loading

    /// Computes derived state from the shared store.
    func loadData() {
        weeklySpending = buildWeeklySpending()
        noSpendStreak = MockDataService.noSpendStreak(from: store.transactions)
        motivationalMessage = Self.randomMotivationalMessage()
        budgetStore.recalculateSpending(from: store.transactions)
    }

    // MARK: - Weekly Spending Builder

    /// Aggregates expenses per day for the last 7 days,
    /// and also computes the matching day from the previous week for comparison.
    private func buildWeeklySpending() -> [DailySpending] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"   // Mon, Tue, Wed …

        // Fetch persisted previous-week transactions from the shared store
        // (they were seeded into SwiftData and live alongside current-week data).
        let previousWeekTransactions = store.transactions.filter {
            let daysAgo = Calendar.current.dateComponents([.day], from: $0.date, to: .now).day ?? 0
            return daysAgo >= 7 && daysAgo <= 13
        }

        return (0..<7).reversed().map { daysAgo in
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let previousDay = calendar.date(byAdding: .day, value: -7, to: day)!
            let label = formatter.string(from: day)

            // Current week total for this day
            let currentTotal = transactions
                .filter { $0.type == .expense && calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.amount }

            // Previous week total for the corresponding day
            let previousTotal = previousWeekTransactions
                .filter { $0.type == .expense && calendar.isDate($0.date, inSameDayAs: previousDay) }
                .reduce(0) { $0 + $1.amount }

            return DailySpending(day: label, amount: currentTotal, previousAmount: previousTotal)
        }
    }

    // MARK: - Motivational Messages

    /// Pool of short, positive messages shown in the nav title area.
    /// Selection is time-of-day aware for extra relevance.
    private static func randomMotivationalMessage() -> String {
        let hour = Calendar.current.component(.hour, from: .now)

        let morningMessages = [
            "Let's save more today 💰",
            "New day, new savings goal ☀️",
            "Track smart, spend smarter 📊",
        ]

        let afternoonMessages = [
            "You're doing great, keep tracking! 🙌",
            "Every rupee counts 👀",
            "Stay on top of your money 💪",
        ]

        let eveningMessages = [
            "Great day for your wallet? 🌙",
            "Review your day, plan tomorrow 📝",
            "Savings grow while you sleep 😴",
        ]

        let nightMessages = [
            "Rest easy, your finances are tracked 🌟",
            "Tomorrow is another chance to save 🌙",
            "Good financial habits start now ✨",
        ]

        switch hour {
        case 5..<12:  return morningMessages.randomElement()!
        case 12..<17: return afternoonMessages.randomElement()!
        case 17..<21: return eveningMessages.randomElement()!
        default:      return nightMessages.randomElement()!
        }
    }
}
