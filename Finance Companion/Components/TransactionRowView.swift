//
//  TransactionRowView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - TransactionRowView

/// A single row in a transaction list with category icon, note, and amount.
struct TransactionRowView: View {

    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            // Category icon
            Image(systemName: transaction.category.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Title & category
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.note.isEmpty ? transaction.category.rawValue : transaction.note)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(transaction.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount & time
            VStack(alignment: .trailing, spacing: 3) {
                Text(amountText)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(transaction.type == .income ? Color(hex: "10B981") : Color(hex: "EF4444"))

                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Helpers

    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(transaction.amount.currencyFormatted)"
    }

    private var iconBackground: LinearGradient {
        transaction.type == .income
            ? LinearGradient(colors: [Color(hex: "10B981"), Color(hex: "059669")],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                             startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TransactionRowView(transaction: .init(
            amount: 85_000, type: .income, category: .salary,
            date: .now, note: "April salary"
        ))
        TransactionRowView(transaction: .init(
            amount: 450, type: .expense, category: .food,
            date: .now, note: "Lunch at café"
        ))
    }
    .padding()
}
