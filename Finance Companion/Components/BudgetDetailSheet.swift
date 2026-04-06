//
//  BudgetDetailSheet.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - BudgetDetailSheet

/// Bottom sheet shown when tapping a budget card.
/// Displays detailed stats, allows editing the budget limit,
/// and provides a link to View All Budgets.
struct BudgetDetailSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs

    let budget: Budget
    let maxAllowed: Double
    let onUpdate: (Double) -> Void
    let onViewAll: () -> Void

    // MARK: - State

    @State private var limitText: String = ""
    @State private var isEditing: Bool = false

    // MARK: - Computed

    private var newLimit: Double? { Double(limitText) }

    private var hasChanged: Bool {
        guard let nl = newLimit else { return false }
        return nl != budget.limit
    }

    private var isValid: Bool {
        guard let nl = newLimit, nl > 0, nl <= maxAllowed else { return false }
        return true
    }

    private var exceedsLimit: Bool {
        guard let nl = newLimit else { return false }
        return nl > maxAllowed
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    progressSection
                    statsGrid
                    editSection
                    
                    viewAllButton
                        .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(budget.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                limitText = String(format: "%.0f", budget.limit)
            }
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: 16) {
            // Large icon
            Image(systemName: budget.category.iconName)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(statusGradient)
                        .frame(
                            width: min(CGFloat(budget.progress) * geo.size.width, geo.size.width),
                            height: 10
                        )
                }
            }
            .frame(height: 10)

            // Percentage
            Text("\(Int(budget.progress * 100))% used")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(statusColor)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(title: "Budget", value: budget.limit.currencyFormatted, color: Color(hex: "6366F1"))
            statCard(title: "Spent", value: budget.spent.currencyFormatted, color: statusColor)
            statCard(
                title: budget.progress > 1.0 ? "Over" : "Left",
                value: budget.progress > 1.0
                    ? (budget.spent - budget.limit).currencyFormatted
                    : budget.remaining.currencyFormatted,
                color: statusColor
            )
        }
    }

    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Edit Section

    private var editSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit Budget")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("₹")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)

                TextField("0", text: $limitText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)

                Spacer()

                if hasChanged {
                    Button("Save") {
                        guard let nl = newLimit, isValid else { return }
                        onUpdate(nl)
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "6366F1"))
                    .clipShape(Capsule())
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if exceedsLimit {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("Budget can't exceed remaining income")
                        .font(.caption)
                }
                .foregroundStyle(Color(hex: "EF4444"))
            }
        }
    }

    // MARK: - View All Button

    private var viewAllButton: some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onViewAll()
            }
        } label: {
            HStack {
                Text("View All Budgets")
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(Color(hex: "6366F1"))
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

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
}

// MARK: - Preview

#Preview {
    BudgetDetailSheet(
        budget: Budget(category: .food, limit: 5000, spent: 3200),
        maxAllowed: 50_000,
        onUpdate: { _ in },
        onViewAll: {}
    )
}
