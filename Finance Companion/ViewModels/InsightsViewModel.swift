//
//  InsightsViewModel.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import Observation
import SwiftUI

// MARK: - Time Range

enum TimeRange: String, CaseIterable, Identifiable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    var id: String { self.rawValue }
}

struct InsightCard: Identifiable {
    let id = UUID()
    let headline: String
    let description: String
    let iconName: String
    let iconColor: Color
}

// MARK: - Category Breakdown

struct CategoryBreakdown: Identifiable {
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
    var id: String { category.id }
}

// MARK: - Insights View Model

@Observable
class InsightsViewModel {
    var timeRange: TimeRange = .thisWeek
    
    // Dependencies
    private var transactionStore = TransactionStore.shared
    private var budgetStore = BudgetStore.shared
    
    // Formatters
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    var hasNoTransactions: Bool {
        transactionStore.transactions.isEmpty
    }
    
    private var currentPeriodTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date.now
        
        return transactionStore.transactions.filter {
            $0.type == .expense && isDate($0.date, inPeriodOffsetBy: 0)
        }
    }
    
    private var previousPeriodTransactions: [Transaction] {
        return transactionStore.transactions.filter {
            $0.type == .expense && isDate($0.date, inPeriodOffsetBy: -1)
        }
    }
    
    var totalSpent: Double {
        currentPeriodTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var previousSpent: Double {
        previousPeriodTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var formattedTotalSpent: String {
        currencyFormatter.string(from: NSNumber(value: totalSpent)) ?? "₹0"
    }
    
    var percentageChange: Double {
        let prev = previousSpent
        guard prev > 0 else { return totalSpent > 0 ? 100 : 0 }
        let change = totalSpent - prev
        return (change / prev) * 100
    }
    
    var trendText: String {
        let percent = Int(abs(percentageChange))
        let change = totalSpent - previousSpent
        
        let formattedPrev = currencyFormatter.string(from: NSNumber(value: previousSpent)) ?? "₹0"
        let formattedChange = currencyFormatter.string(from: NSNumber(value: abs(change))) ?? "₹0"
        
        let timeSuffix = timeRange == .thisWeek ? "last week" : "last month"
        
        if previousSpent == 0 {
            return "First \(timeRange == .thisWeek ? "week" : "month") tracked! 🎯"
        } else if change > 0 {
            return "↑ \(percent)% (+\(formattedChange)) from \(formattedPrev) \(timeSuffix)"
        } else if change < 0 {
            return "↓ \(percent)% (-\(formattedChange)) from \(formattedPrev) \(timeSuffix)"
        } else {
            return "Same as \(timeSuffix) (\(formattedPrev))"
        }
    }
    
    var categoryBreakdowns: [CategoryBreakdown] {
        let total = totalSpent
        guard total > 0 else { return [] }
        
        var categoryTotals: [TransactionCategory: Double] = [:]
        for tx in currentPeriodTransactions {
            categoryTotals[tx.category, default: 0] += tx.amount
        }
        
        return categoryTotals.map { category, amount in
            CategoryBreakdown(category: category, amount: amount, percentage: amount / total)
        }.sorted { $0.amount > $1.amount }
    }
    
    var sparklineData: [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let daysCount = timeRange == .thisWeek ? 7 : 30
        
        var points: [Double] = []
        for i in (0..<daysCount).reversed() {
            let day = calendar.date(byAdding: .day, value: -i, to: today)!
            let dailyTotal = currentPeriodTransactions
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.amount }
            points.append(dailyTotal)
        }
        return points
    }
    
    var topCategoryHighlight: String? {
        guard let top = categoryBreakdowns.first else { return nil }
        let percent = Int(top.percentage * 100)
        return "Top category: \(top.category.rawValue) (\(percent)%)"
    }
    
    var insightCards: [InsightCard] {
        var cards: [InsightCard] = []
        
        // Insight 1: Highest category
        if let topCategory = categoryBreakdowns.first {
            cards.append(InsightCard(
                headline: topCategory.category.rawValue,
                description: "Your highest spending category",
                iconName: topCategory.category.iconName,
                iconColor: topCategory.category.rawColor
            ))
        }
        
        // Insight 2: Highest Day
        if !currentPeriodTransactions.isEmpty {
            let calendar = Calendar.current
            var dayTotals: [Int: Double] = [:]
            for tx in currentPeriodTransactions {
                let weekday = calendar.component(.weekday, from: tx.date)
                dayTotals[weekday, default: 0] += tx.amount
            }
            if let topDayIndex = dayTotals.max(by: { $0.value < $1.value })?.key {
                let formatter = DateFormatter()
                let dayName = formatter.weekdaySymbols[topDayIndex - 1]
                cards.append(InsightCard(
                    headline: dayName,
                    description: "Your highest spending day",
                    iconName: "calendar",
                    iconColor: Color.orange
                ))
            }
        }
        
        if cards.isEmpty {
            cards.append(InsightCard(
                headline: "No data",
                description: "Add some expenses to see insights",
                iconName: "chart.line.uptrend.xyaxis",
                iconColor: .gray
            ))
        }
        
        return cards
    }
    
    var budgetAlerts: [String] {
        budgetStore.budgets.compactMap { budget in
            if budget.status == .exceeded {
                return "\(budget.category.rawValue) budget exceeded 🔴"
            } else if budget.status == .warning {
                return "You're close to your \(budget.category.rawValue) budget ⚠️"
            }
            return nil
        }
    }
    
    // MARK: - PDF Report Data
    
    var reportPeriodString: String {
        timeRange == .thisWeek ? "This Week" : "This Month"
    }
    
    var reportSummaryString: String {
        let change = totalSpent - previousSpent
        let percent = Int(abs(percentageChange))
        let symbol = change > 0 ? "↑" : (change < 0 ? "↓" : "")
        let sign = change > 0 ? "+" : (change < 0 ? "−" : "")
        
        let formattedChange = currencyFormatter.string(from: NSNumber(value: abs(change))) ?? "₹0"
        let formattedPrev = currencyFormatter.string(from: NSNumber(value: previousSpent)) ?? "₹0"
        let formattedTotal = currencyFormatter.string(from: NSNumber(value: totalSpent)) ?? "₹0"
        
        let timeCurrent = timeRange == .thisWeek ? "this week" : "this month"
        let timePrevious = timeRange == .thisWeek ? "last week" : "last month"
        
        if previousSpent == 0 {
            return "\(formattedTotal) \(timeCurrent)"
        } else if change == 0 {
            return "\(formattedTotal) \(timeCurrent) vs \(formattedPrev) \(timePrevious) (No change)"
        } else {
            return "\(formattedTotal) \(timeCurrent) vs \(formattedPrev) \(timePrevious) (\(symbol) \(percent)%, \(sign)\(formattedChange))"
        }
    }
    
    var reportObservationText: String? {
        let change = totalSpent - previousSpent
        if previousSpent == 0 {
            return nil
        } else if change < 0 {
            return "You reduced your spending this period. Great job!"
        } else if change > 0 {
            return "Your spending increased this period. Consider reviewing your expenses."
        } else {
            return "Your spending remained exactly the same as the previous period."
        }
    }
    
    // MARK: - Helpers
    
    private func isDate(_ date: Date, inPeriodOffsetBy offset: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        if timeRange == .thisWeek {
            // Rolling 7-day window. Offset 0 is today and 6 preceding days.
            let daysOffset = offset * 7
            let start = calendar.date(byAdding: .day, value: daysOffset - 6, to: today)!
            let end = calendar.date(byAdding: .day, value: daysOffset + 1, to: today)!
            return date >= start && date < end
        } else {
            guard let startOfCurrentMonth = calendar.dateInterval(of: .month, for: .now)?.start,
                  let targetMonthStart = calendar.date(byAdding: .month, value: offset, to: startOfCurrentMonth),
                  let targetMonthEnd = calendar.date(byAdding: .month, value: 1, to: targetMonthStart) else { return false }
            return date >= targetMonthStart && date < targetMonthEnd
        }
    }
    
}

extension TransactionCategory {
    var rawColor: Color {
        switch self {
        case .salary: return Color(hex: "34D399")
        case .freelance: return Color(hex: "60A5FA")
        case .food: return Color(hex: "F87171")
        case .transport: return Color(hex: "FBBF24")
        case .entertainment: return Color(hex: "A78BFA")
        case .shopping: return Color(hex: "F472B6")
        case .utilities: return Color(hex: "9CA3AF")
        case .health: return Color(hex: "10B981")
        case .education: return Color(hex: "3B82F6")
        case .other: return Color(hex: "6366F1")
        }
    }
}
