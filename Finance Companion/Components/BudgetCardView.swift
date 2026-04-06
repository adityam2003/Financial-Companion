//
//  BudgetCardView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - BudgetCardView

/// Compact card for the Home horizontal scroll.
/// Shows category, spent/limit, color-coded progress bar, and remaining.
struct BudgetCardView: View {

    let budget: Budget
    let onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon + category
                HStack(spacing: 10) {
                    Image(systemName: budget.category.iconName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(iconGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text(budget.category.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }

                // Spent / Limit
                Text("\(budget.spent.currencyFormatted) / \(budget.limit.currencyFormatted)")
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundStyle(.secondary)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(statusGradient)
                            .frame(
                                width: min(CGFloat(budget.progress) * geo.size.width, geo.size.width),
                                height: 6
                            )
                            .animation(.easeInOut(duration: 0.4), value: budget.progress)
                    }
                }
                .frame(height: 6)

                // Remaining
                Text(remainingText)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(statusColor)
            }
            .padding(14)
            .frame(width: 165)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var remainingText: String {
        if budget.progress > 1.0 {
            let over = budget.spent - budget.limit
            return "\(over.currencyFormatted) over"
        }
        return "\(budget.remaining.currencyFormatted) left"
    }

    private var statusColor: Color {
        switch budget.status {
        case .safe:     return Color(hex: "10B981")
        case .warning:  return Color(hex: "F59E0B")
        case .exceeded: return Color(hex: "EF4444")
        }
    }

    private var statusGradient: LinearGradient {
        switch budget.status {
        case .safe:
            return LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "059669")],
                startPoint: .leading, endPoint: .trailing
            )
        case .warning:
            return LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                startPoint: .leading, endPoint: .trailing
            )
        case .exceeded:
            return LinearGradient(
                colors: [Color(hex: "EF4444"), Color(hex: "DC2626")],
                startPoint: .leading, endPoint: .trailing
            )
        }
    }

    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview {
    HStack {
        BudgetCardView(
            budget: Budget(category: .food, limit: 5000, spent: 3200),
            onTap: {}
        )
        BudgetCardView(
            budget: Budget(category: .transport, limit: 2000, spent: 1800),
            onTap: {}
        )
        BudgetCardView(
            budget: Budget(category: .shopping, limit: 3000, spent: 3500),
            onTap: {}
        )
    }
    .padding()
}
