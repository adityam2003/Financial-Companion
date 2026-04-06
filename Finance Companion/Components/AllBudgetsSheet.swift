//
//  AllBudgetsSheet.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - AllBudgetsSheet

/// Full-screen sheet listing all budgets with add, edit, and delete capabilities.
struct AllBudgetsSheet: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel

    @Bindable var viewModel: BudgetViewModel

    // MARK: - State

    @State private var showingAddSheet = false
    @State private var selectedBudget: Budget? = nil
    @State private var showingEditTotalSheet = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // Total budget + allocation summary
                Section {
                    totalBudgetBanner
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

                // Budget rows
                if viewModel.allBudgets.isEmpty {
                    Section {
                        emptyState
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    Section {
                        ForEach(viewModel.allBudgets) { budget in
                            budgetRow(budget)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.deleteBudget(budget)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    selectedBudget = budget
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("All Budgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if viewModel.isBudgetFull || viewModel.availableCategories.isEmpty {
                            viewModel.showingBudgetFullAlert = true
                        } else {
                            showingAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "6366F1"))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBudgetSheet(
                    availableCategories: viewModel.availableCategories,
                    remainingAllocatable: viewModel.remainingAllocatable,
                    onSave: { category, limit in
                        viewModel.addBudget(category: category, limit: limit)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedBudget) { budget in
                BudgetDetailSheet(
                    budget: budget,
                    maxAllowed: viewModel.maxAllowedForEdit(budget),
                    onUpdate: { newLimit in
                        viewModel.updateBudget(budget, newLimit: newLimit)
                    },
                    onViewAll: {}  // already on this screen
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingEditTotalSheet) {
                SetTotalBudgetSheet(
                    currentTotal: viewModel.totalBudget,
                    hasBudgets: viewModel.hasBudgets,
                    onSave: { newValue in
                        viewModel.setTotalBudget(newValue)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .alert(
                "Budget Full",
                isPresented: $viewModel.showingBudgetFullAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your budget is fully allocated. Edit your total budget or remove a category budget to add more.")
            }
        }
    }

    // MARK: - Total Budget Banner

    private var totalBudgetBanner: some View {
        VStack(spacing: 14) {
            // Total budget header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(viewModel.totalBudget.currencyFormatted)
                        .font(.title2.weight(.bold).monospacedDigit())
                        .foregroundStyle(.primary)
                }

                Spacer()

                Button {
                    showingEditTotalSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(hex: "6366F1"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "6366F1").opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            // Allocation progress
            VStack(spacing: 6) {
                HStack {
                    Text("Allocated")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.totalAllocated.currencyFormatted) of \(viewModel.totalBudget.currencyFormatted)")
                        .font(.caption.weight(.medium).monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    let ratio = viewModel.totalBudget > 0
                        ? min(viewModel.totalAllocated / viewModel.totalBudget, 1.0)
                        : 0.0

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: CGFloat(ratio) * geo.size.width, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(viewModel.remainingAllocatable.currencyFormatted) available")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "10B981"))
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Budget Row

    private func budgetRow(_ budget: Budget) -> some View {
        HStack(spacing: 12) {
            Image(systemName: budget.category.iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(budget.category.rawValue)
                    .font(.subheadline.weight(.medium))

                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(statusColor(for: budget))
                            .frame(
                                width: min(CGFloat(budget.progress) * geo.size.width, geo.size.width),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(budget.spent.currencyFormatted)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(statusColor(for: budget))

                Text("of \(budget.limit.currencyFormatted)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No Category Budgets Yet")
                .font(.title3.weight(.semibold))

            Text("Tap + to split your \(viewModel.totalBudget.currencyFormatted) into categories")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func statusColor(for budget: Budget) -> Color {
        switch budget.status {
        case .safe:     return Color(hex: "10B981")
        case .warning:  return Color(hex: "F59E0B")
        case .exceeded: return Color(hex: "EF4444")
        }
    }
}

// MARK: - Preview

#Preview {
    AllBudgetsSheet(viewModel: BudgetViewModel())
}
