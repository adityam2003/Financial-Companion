//
//  TransactionsView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

// MARK: - TransactionsView

/// Full transactions screen with search, filters, grouped list, and add/edit flow.
struct TransactionsView: View {

    @State private var viewModel = TransactionsViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                mainContent
                addButton
            }
            .navigationTitle("Transactions")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search transactions"
            )
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddTransactionSheet(
                    editingTransaction: viewModel.editingTransaction,
                    onSave: { amount, type, category, note, date in
                        viewModel.addTransaction(
                            amount: amount, type: type,
                            category: category, note: note, date: date
                        )
                    },
                    onUpdate: { id, amount, type, category, note, date in
                        viewModel.updateTransaction(
                            id: id, amount: amount, type: type,
                            category: category, note: note, date: date
                        )
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        List {
            // Filter chips section (no separator)
            Section {
                filterChips
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 0, trailing: 16))

            if viewModel.groupedTransactions.isEmpty {
                // Empty state
                Section {
                    emptyState
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                // Grouped transaction sections
                ForEach(viewModel.groupedTransactions) { group in
                    Section {
                        ForEach(group.transactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.deleteTransaction(transaction)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        viewModel.editingTransaction = transaction
                                        viewModel.showingAddSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color(hex: "6366F1"))
                                }
                        }
                    } header: {
                        HStack {
                            Text(group.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                            Spacer()
                            Text("\(group.transactions.count)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        HStack(spacing: 10) {
            ForEach(TransactionFilter.allCases) { filter in
                FilterChipView(
                    title: filter.rawValue,
                    isSelected: viewModel.selectedFilter == filter
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Transactions")
                .font(.title3.weight(.semibold))

            Text(viewModel.searchText.isEmpty
                 ? "Tap + to add your first transaction"
                 : "No results for \"\(viewModel.searchText)\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Floating Add Button

    private var addButton: some View {
        Button {
            viewModel.editingTransaction = nil
            viewModel.showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - FilterChipView

/// A single capsule filter chip with tap handling.
struct FilterChipView: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color(.tertiarySystemFill))
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TransactionsView()
}
