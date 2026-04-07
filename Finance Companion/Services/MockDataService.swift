//
//  MockDataService.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import Foundation
import SwiftData

// MARK: - MockDataService

/// Provides mock transaction data for the demo app.
/// Call `seedIfNeeded(context:)` exactly once at launch — it is guarded by a UserDefaults flag.
struct MockDataService {

    // MARK: - Seed Guard Key

    private static let seedKey = "hasSeededMockData"

    // MARK: - Date Helper

    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
    }

    // MARK: - One-Time Seeding

    /// Seeds mock transactions into SwiftData on the very first app launch.
    ///
    /// - Parameters:
    ///   - context: The SwiftData `ModelContext` to insert transactions into.
    ///   - force:   If `true`, bypasses the UserDefaults guard. Use only for Previews / tests.
    static func seedIfNeeded(context: ModelContext, force: Bool = false) {
        guard force || !UserDefaults.standard.bool(forKey: seedKey) else { return }

        let allTransactions = makeSampleTransactions() + makePreviousWeekTransactions()
        for transaction in allTransactions {
            context.insert(transaction)
        }

        do {
            try context.save()
            if !force {
                UserDefaults.standard.set(true, forKey: seedKey)
            }
        } catch {
            print("[MockDataService] Seed failed: \(error)")
        }
    }

    // MARK: - Sample Transactions (factory — returns fresh instances each call)

    /// Current-week mock transactions.
    static func makeSampleTransactions() -> [Transaction] {[
        // Income
        Transaction(amount: 85_000, type: .income, category: .salary,
                    date: date(daysAgo: 0), note: "April salary"),
        Transaction(amount: 12_000, type: .income, category: .freelance,
                    date: date(daysAgo: 2), note: "Logo design project"),
        Transaction(amount: 5_000,  type: .income, category: .freelance,
                    date: date(daysAgo: 5), note: "Blog writing"),

        // Expenses – spread across the week
        Transaction(amount: 450,   type: .expense, category: .food,
                    date: date(daysAgo: 0), note: "Lunch at café"),
        Transaction(amount: 1_200, type: .expense, category: .shopping,
                    date: date(daysAgo: 0), note: "New headphones"),
        Transaction(amount: 200,   type: .expense, category: .transport,
                    date: date(daysAgo: 1), note: "Uber to office"),
        Transaction(amount: 800,   type: .expense, category: .entertainment,
                    date: date(daysAgo: 1), note: "Movie night"),
        Transaction(amount: 350,   type: .expense, category: .food,
                    date: date(daysAgo: 2), note: "Groceries"),
        Transaction(amount: 2_500, type: .expense, category: .utilities,
                    date: date(daysAgo: 3), note: "Electricity bill"),
        Transaction(amount: 600,   type: .expense, category: .food,
                    date: date(daysAgo: 3), note: "Dinner with friends"),
        Transaction(amount: 1_500, type: .expense, category: .health,
                    date: date(daysAgo: 4), note: "Gym membership"),
        Transaction(amount: 300,   type: .expense, category: .transport,
                    date: date(daysAgo: 5), note: "Metro recharge"),
        Transaction(amount: 4_000, type: .expense, category: .education,
                    date: date(daysAgo: 6), note: "Online course"),
        Transaction(amount: 750,   type: .expense, category: .shopping,
                    date: date(daysAgo: 6), note: "Books"),
    ]}

    /// Previous-week mock transactions (used for week-over-week comparison).
    static func makePreviousWeekTransactions() -> [Transaction] {[
        Transaction(amount: 600,   type: .expense, category: .food,
                    date: date(daysAgo: 7),  note: "Restaurant dinner"),
        Transaction(amount: 900,   type: .expense, category: .shopping,
                    date: date(daysAgo: 7),  note: "Clothes"),
        Transaction(amount: 350,   type: .expense, category: .transport,
                    date: date(daysAgo: 8),  note: "Cab rides"),
        Transaction(amount: 1_200, type: .expense, category: .entertainment,
                    date: date(daysAgo: 8),  note: "Concert tickets"),
        Transaction(amount: 500,   type: .expense, category: .food,
                    date: date(daysAgo: 9),  note: "Takeout"),
        Transaction(amount: 1_800, type: .expense, category: .utilities,
                    date: date(daysAgo: 10), note: "Internet bill"),
        Transaction(amount: 400,   type: .expense, category: .food,
                    date: date(daysAgo: 10), note: "Coffee & snacks"),
        Transaction(amount: 2_000, type: .expense, category: .health,
                    date: date(daysAgo: 11), note: "Doctor visit"),
        Transaction(amount: 250,   type: .expense, category: .transport,
                    date: date(daysAgo: 12), note: "Bus pass"),
        Transaction(amount: 3_500, type: .expense, category: .education,
                    date: date(daysAgo: 13), note: "Workshop fee"),
        Transaction(amount: 650,   type: .expense, category: .shopping,
                    date: date(daysAgo: 13), note: "Stationery"),
    ]}

    // MARK: - No-Spend Streak

    /// Number of consecutive days (including today if no expenses yet) with zero expenses.
    static func noSpendStreak(from transactions: [Transaction]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let expenseDays: Set<Date> = Set(
            transactions
                .filter { $0.type == .expense }
                .map { calendar.startOfDay(for: $0.date) }
        )

        var streak = 0
        var checkDate = today   // start from today

        while !expenseDays.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
            if streak >= 30 { break }
        }

        return streak
    }
}
