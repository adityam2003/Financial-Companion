//
//  AddTransactionSheet.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - AddTransactionSheet

/// Bottom sheet for adding or editing a transaction.
/// When `editingTransaction` is non-nil, the sheet opens in edit mode with pre-filled values.
struct AddTransactionSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inputs

    let editingTransaction: Transaction?
    let onSave: (Double, TransactionType, TransactionCategory, String, Date) -> Void
    let onUpdate: (UUID, Double, TransactionType, TransactionCategory, String, Date) -> Void

    // MARK: - Form State

    @State private var amountText: String = ""
    @State private var type: TransactionType = .expense
    @State private var category: TransactionCategory = .food
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var showBudgetPrompt: Bool = true
    @State private var showingAddBudgetFromPrompt: Bool = false
    @FocusState private var amountFocused: Bool

    // MARK: - Budget

    private let budgetVM = BudgetViewModel()

    // MARK: - Computed

    private var isEditing: Bool { editingTransaction != nil }

    private var isFormValid: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        return true
    }

    // MARK: - Category Grid Layout

    private let categoryColumns = [
        GridItem(.adaptive(minimum: 72), spacing: 12)
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Budget prompt (first-time, no budgets)
                    if !budgetVM.hasBudgets && !isEditing && showBudgetPrompt {
                        budgetPromptBanner
                    }

                    amountSection
                    typeToggle
                    categorySection

                    // Budget insight for selected category
                    if type == .expense, let insight = budgetVM.budgetInsight(for: category) {
                        budgetInsightBanner(insight)
                    }

                    noteSection
                    dateSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isFormValid)
                }
            }
            .onAppear { prefillIfEditing() }
            .sheet(isPresented: $showingAddBudgetFromPrompt) {
                AddBudgetSheet(
                    availableCategories: budgetVM.availableCategories,
                    remainingAllocatable: budgetVM.remainingAllocatable,
                    onSave: { cat, limit in
                        budgetVM.addBudget(category: cat, limit: limit)
                        showBudgetPrompt = false
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Amount

    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("₹")
                .font(.title2.weight(.medium))
                .foregroundStyle(.secondary)

            TextField("0", text: $amountText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($amountFocused)
                .onAppear { amountFocused = true }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Type Toggle

    private var typeToggle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Type")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Picker("Type", selection: $type) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Category Selector

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: categoryColumns, spacing: 12) {
                ForEach(TransactionCategory.allCases) { cat in
                    categoryCell(cat)
                }
            }
        }
    }

    private func categoryCell(_ cat: TransactionCategory) -> some View {
        let isSelected = category == cat
        return VStack(spacing: 6) {
            Image(systemName: cat.iconName)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(cat.rawValue)
                .font(.caption2)
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.accentColor : .primary)
        .onTapGesture { category = cat }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Note

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Note")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            TextField("What was this for?", text: $note)
                .padding(14)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Date

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Actions

    private func prefillIfEditing() {
        guard let tx = editingTransaction else { return }
        amountText = String(format: "%.0f", tx.amount)
        type = tx.type
        category = tx.category
        note = tx.note
        date = tx.date
    }

    private func save() {
        guard let amount = Double(amountText), amount > 0 else { return }
        if let tx = editingTransaction {
            onUpdate(tx.id, amount, type, category, note, date)
        } else {
            onSave(amount, type, category, note, date)
        }
        dismiss()
    }
}

// MARK: - Budget Prompt Banner

extension AddTransactionSheet {

    /// Non-blocking banner prompting the user to set up budgets.
    private var budgetPromptBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.bar.badge.clock")
                .font(.body)
                .foregroundStyle(Color(hex: "6366F1"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Want to set a budget for better tracking?")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button("Set") {
                showingAddBudgetFromPrompt = true
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color(hex: "6366F1"))
            .clipShape(Capsule())

            Button {
                withAnimation { showBudgetPrompt = false }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(hex: "6366F1").opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// Contextual budget insight shown below category grid.
    private func budgetInsightBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.caption)

            Text(message)
                .font(.caption)
        }
        .foregroundStyle(budgetInsightColor)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(budgetInsightColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var budgetInsightColor: Color {
        guard let budget = BudgetStore.shared.budget(for: category) else {
            return Color(hex: "6366F1")
        }
        switch budget.status {
        case .safe:     return Color(hex: "10B981")
        case .warning:  return Color(hex: "F59E0B")
        case .exceeded: return Color(hex: "EF4444")
        }
    }
}

// MARK: - Preview

#Preview("Add Mode") {
    AddTransactionSheet(
        editingTransaction: nil,
        onSave: { _, _, _, _, _ in },
        onUpdate: { _, _, _, _, _, _ in }
    )
}

#Preview("Edit Mode") {
    AddTransactionSheet(
        editingTransaction: Transaction(
            amount: 450, type: .expense, category: .food,
            date: .now, note: "Lunch at café"
        ),
        onSave: { _, _, _, _, _ in },
        onUpdate: { _, _, _, _, _, _ in }
    )
}
