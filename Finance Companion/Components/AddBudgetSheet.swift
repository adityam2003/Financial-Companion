//
//  AddBudgetSheet.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - AddBudgetSheet

/// Bottom sheet for creating a new category budget.
/// Shows available categories (those without budgets) and enforces allocation limits.
struct AddBudgetSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs

    let availableCategories: [TransactionCategory]
    let remainingAllocatable: Double
    let onSave: (TransactionCategory, Double) -> Void

    // MARK: - State

    @State private var selectedCategory: TransactionCategory?
    @State private var amountText: String = ""
    @FocusState private var amountFocused: Bool

    // MARK: - Computed

    private var amount: Double? {
        Double(amountText)
    }

    private var isValid: Bool {
        guard let amt = amount, amt > 0, amt <= remainingAllocatable else { return false }
        return selectedCategory != nil
    }

    private var exceedsLimit: Bool {
        guard let amt = amount else { return false }
        return amt > remainingAllocatable
    }

    // MARK: - Category Grid

    private let columns = [
        GridItem(.adaptive(minimum: 72), spacing: 12)
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    allocationHeader
                    categoryPicker
                    amountSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Allocation Header

    private var allocationHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color(hex: "6366F1"))

            Text("\(remainingAllocatable.currencyFormatted) available to allocate")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(hex: "6366F1").opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if availableCategories.isEmpty {
                Text("All categories have budgets")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(availableCategories) { cat in
                        categoryCell(cat)
                    }
                }
            }
        }
    }

    private func categoryCell(_ cat: TransactionCategory) -> some View {
        let isSelected = selectedCategory == cat
        return VStack(spacing: 6) {
            Image(systemName: cat.iconName)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color(hex: "6366F1").opacity(0.15) : Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(cat.rawValue)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color(hex: "6366F1") : .primary)
        .onTapGesture {
            selectedCategory = cat
            amountFocused = true
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Amount

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Budget")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("₹")
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.secondary)

                TextField("0", text: $amountText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .focused($amountFocused)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if exceedsLimit {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("Budget can't exceed remaining income")
                        .font(.caption)
                }
                .foregroundStyle(Color(hex: "EF4444"))
                .transition(.opacity)
            }
        }
    }

    // MARK: - Actions

    private func save() {
        guard let cat = selectedCategory, let amt = amount, isValid else { return }
        onSave(cat, amt)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddBudgetSheet(
        availableCategories: [.food, .transport, .shopping, .entertainment, .utilities],
        remainingAllocatable: 50_000,
        onSave: { _, _ in }
    )
}
