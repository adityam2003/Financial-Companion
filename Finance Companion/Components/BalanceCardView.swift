//
//  BalanceCardView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - BalanceCardView

/// Hero card showing the user's current balance with a gradient background.
struct BalanceCardView: View {

    let balance: Double
    let income: Double
    let expenses: Double

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            // Balance
            VStack(spacing: 4) {
                Text("Current Balance")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Text(balance.currencyFormatted)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            // Income & Expense pills
            HStack(spacing: 16) {
                summaryPill(
                    title: "Income",
                    amount: income,
                    icon: "arrow.down.circle.fill",
                    tint: .green
                )

                summaryPill(
                    title: "Expenses",
                    amount: expenses,
                    icon: "arrow.up.circle.fill",
                    tint: .red
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "1E3A5F"), Color(hex: "2D6A9F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: "1E3A5F").opacity(0.35), radius: 16, x: 0, y: 8)
    }

    // MARK: - Summary Pill

    @ViewBuilder
    private func summaryPill(title: String, amount: Double, icon: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))

                Text(amount.currencyFormatted)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    BalanceCardView(balance: 89_350, income: 102_000, expenses: 12_650)
        .padding()
}
