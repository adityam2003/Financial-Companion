//
//  Budget.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import SwiftData

// MARK: - Budget Status

/// Visual status derived from spending progress.
enum BudgetStatus {
    case safe       // < 75%
    case warning    // 75–100%
    case exceeded   // > 100%
}

// MARK: - Budget Model

/// SwiftData-persisted model representing a monthly spending limit for a single category.
/// `spent` is computed at runtime from transactions — marked @Transient so it is never stored.
@Model
final class Budget {
    var id: UUID
    var category: TransactionCategory
    var limit: Double

    /// Current month's spending — recalculated at runtime, never persisted.
    @Transient var spent: Double = 0

    // MARK: - Computed

    var remaining: Double { max(limit - spent, 0) }

    /// Progress ratio (0…∞). Values above 1.0 indicate the budget is exceeded.
    var progress: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    /// Color-coding status for the progress bar.
    var status: BudgetStatus {
        switch progress {
        case ..<0.75:    return .safe
        case 0.75...1.0: return .warning
        default:         return .exceeded
        }
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        limit: Double,
        spent: Double = 0
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.spent = spent
    }
}
