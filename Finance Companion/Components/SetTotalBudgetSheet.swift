//
//  SetTotalBudgetSheet.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - SetTotalBudgetSheet

/// Bottom sheet for the user to enter or update their total monthly budget.
/// Handles the destructive alert INTERNALLY when the user lowers the budget,
/// so the alert lives in the same view hierarchy as the presenting sheet.
struct SetTotalBudgetSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs

    let currentTotal: Double
    let hasBudgets: Bool
    let onSave: (Double) -> Void

    // MARK: - State

    @State private var amountText: String = ""
    @State private var showingResetAlert: Bool = false
    @FocusState private var amountFocused: Bool

    // MARK: - Computed

    private var amount: Double? { Double(amountText) }
    private var isValid: Bool {
        guard let amt = amount, amt > 0 else { return false }
        return true
    }

    private var isFirstTime: Bool { currentTotal == 0 }

    /// True when the new value is lower AND there are existing category budgets to reset.
    private var isDestructive: Bool {
        guard let amt = amount else { return false }
        return amt < currentTotal && hasBudgets
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                // Header illustration
                VStack(spacing: 12) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )

                    Text(isFirstTime
                         ? "How much do you want to budget this month?"
                         : "Update your monthly budget")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    if !isFirstTime {
                        Text("Current: \(currentTotal.currencyFormatted)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 12)

                // Amount input
                VStack(spacing: 8) {
                    Text("₹")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.secondary)

                    TextField("0", text: $amountText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($amountFocused)
                        .onAppear {
                            if currentTotal > 0 {
                                amountText = String(format: "%.0f", currentTotal)
                            }
                            amountFocused = true
                        }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                // Destructive warning hint
                if isDestructive {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("This will reset all your category budgets")
                            .font(.caption)
                    }
                    .foregroundStyle(Color(hex: "EF4444"))
                    .transition(.opacity)
                } else {
                    // Normal hint
                    Text("You can split this into category budgets next")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isFirstTime ? "Set Budget" : "Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard isValid else { return }
                        if isDestructive {
                            // Show confirmation alert before proceeding
                            showingResetAlert = true
                        } else {
                            // Safe — apply and dismiss
                            onSave(amount!)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .alert(
                "Reset All Budgets?",
                isPresented: $showingResetAlert
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Reset & Update", role: .destructive) {
                    onSave(amount!)
                    dismiss()
                }
            } message: {
                Text("Lowering your total budget will remove all existing category budgets. You'll need to set them up again.")
            }
        }
    }
}

// MARK: - Preview

#Preview("First Time") {
    SetTotalBudgetSheet(currentTotal: 0, hasBudgets: false, onSave: { _ in })
}

#Preview("Update") {
    SetTotalBudgetSheet(currentTotal: 50_000, hasBudgets: true, onSave: { _ in })
}
