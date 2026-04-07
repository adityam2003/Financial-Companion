//
//  Transaction.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import Foundation
import SwiftData

// MARK: - Transaction Type

/// Distinguishes between money coming in and money going out.
enum TransactionType: String, CaseIterable, Identifiable, Codable {
    case income
    case expense

    var id: String { rawValue }
}

// MARK: - Transaction Category

/// Predefined spending / earning categories.
enum TransactionCategory: String, CaseIterable, Identifiable, Codable {
    case salary        = "Salary"
    case freelance     = "Freelance"
    case food          = "Food"
    case transport     = "Transport"
    case entertainment = "Entertainment"
    case shopping      = "Shopping"
    case utilities     = "Utilities"
    case health        = "Health"
    case education     = "Education"
    case other         = "Other"

    var id: String { rawValue }

    /// SF Symbol name mapped to each category.
    var iconName: String {
        switch self {
        case .salary:        return "banknote"
        case .freelance:     return "laptopcomputer"
        case .food:          return "fork.knife"
        case .transport:     return "car.fill"
        case .entertainment: return "tv.fill"
        case .shopping:      return "bag.fill"
        case .utilities:     return "bolt.fill"
        case .health:        return "heart.fill"
        case .education:     return "book.fill"
        case .other:         return "ellipsis.circle"
        }
    }
}

// MARK: - Transaction Model

/// SwiftData-persisted model representing a single financial transaction.
@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var category: TransactionCategory
    var date: Date
    var note: String

    init(
        id: UUID = UUID(),
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        date: Date,
        note: String = ""
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.note = note
    }
}

// MARK: - Weekly Spending Data Point

/// A single bar in the weekly spending chart.
/// Optionally carries previous week data for comparison.
/// This is a transient display model — never persisted.
struct DailySpending: Identifiable {
    let id = UUID()
    let day: String           // e.g. "Mon"
    let amount: Double        // current week
    var previousAmount: Double = 0  // previous week (for comparison)
    var isToday: Bool = false       // highlights today's bar in the chart
}
