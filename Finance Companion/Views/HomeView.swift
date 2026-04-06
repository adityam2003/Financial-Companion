//
//  HomeView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - HomeView

/// Main dashboard screen.
/// Composes all the card components into a scrollable layout.
struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var budgetVM = BudgetViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Dynamic motivational message
                    motivationalBanner

                    // Hero balance card
                    BalanceCardView(
                        balance: viewModel.currentBalance,
                        income: viewModel.totalIncome,
                        expenses: viewModel.totalExpenses
                    )

                    // Weekly spending chart with comparison + insight
                    WeeklyChartView(
                        data: viewModel.weeklySpending,
                        insight: viewModel.spendingInsight,
                        isPositiveTrend: viewModel.isSpendingDown,
                        hasEnoughHistory: viewModel.hasEnoughHistory
                    )

                    // No-spend streak with ViewModel-driven message
                    StreakProgressView(
                        streakDays: viewModel.noSpendStreak,
                        streakMessage: viewModel.streakMessage
                    )

                    // Budgets section
                    budgetsSection

                    // Recent transactions (hidden when empty)
                    if !viewModel.transactions.isEmpty {
                        recentTransactionsSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .onAppear {
                budgetVM.recalculate()
            }
            .sheet(isPresented: $budgetVM.showingSetTotalBudgetSheet) {
                SetTotalBudgetSheet(
                    currentTotal: budgetVM.totalBudget,
                    hasBudgets: budgetVM.hasBudgets,
                    onSave: { newValue in
                        budgetVM.setTotalBudget(newValue)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $budgetVM.showingAddBudgetSheet) {
                AddBudgetSheet(
                    availableCategories: budgetVM.availableCategories,
                    remainingAllocatable: budgetVM.remainingAllocatable,
                    onSave: { category, limit in
                        budgetVM.addBudget(category: category, limit: limit)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $budgetVM.showingBudgetDetail) { budget in
                BudgetDetailSheet(
                    budget: budget,
                    maxAllowed: budgetVM.maxAllowedForEdit(budget),
                    onUpdate: { newLimit in
                        budgetVM.updateBudget(budget, newLimit: newLimit)
                    },
                    onViewAll: {
                        budgetVM.showingAllBudgets = true
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $budgetVM.showingAllBudgets) {
                AllBudgetsSheet(viewModel: budgetVM)
            }
            .alert(
                "Budget Full",
                isPresented: $budgetVM.showingBudgetFullAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your budget is fully allocated. Edit your total budget or remove a category budget to add more.")
            }
        }
    }

    // MARK: - Motivational Banner

    private var motivationalBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.subheadline)
                .foregroundStyle(Color(hex: "F59E0B"))

            Text(viewModel.motivationalMessage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(
                title: "Recent Transactions",
                icon: "clock.fill"
            )

            VStack(spacing: 0) {
                ForEach(viewModel.transactions.prefix(5)) { transaction in
                    TransactionRowView(transaction: transaction)

                    if transaction.id != viewModel.transactions.prefix(5).last?.id {
                        Divider()
                            .padding(.leading, 54)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    // MARK: - Budgets Section

    private var budgetsSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(
                title: "Budgets",
                icon: "chart.bar.fill",
                actionTitle: budgetVM.hasBudgets ? "View All" : nil
            ) {
                budgetVM.showingAllBudgets = true
            }

            if budgetVM.hasBudgets {
                // Horizontal scroll of budget cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(budgetVM.topBudgets) { budget in
                            BudgetCardView(budget: budget) {
                                budgetVM.showingBudgetDetail = budget
                            }
                        }

                        // Add budget card at the end (always visible)
                        AddBudgetCard {
                            budgetVM.requestAddBudget()
                        }
                    }
                }
            } else {
                // Empty state
                VStack(spacing: 14) {
                    Text(budgetVM.hasTotalBudget
                         ? "Split your \(budgetVM.totalBudget.currencyFormatted) into categories"
                         : "Set your first budget to start tracking 💰")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        if budgetVM.hasTotalBudget {
                            budgetVM.showingAddBudgetSheet = true
                        } else {
                            budgetVM.showingSetTotalBudgetSheet = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text(budgetVM.hasTotalBudget ? "Add Category Budget" : "Set Budget")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    // MARK: - Toolbar Removed
}

// MARK: - Preview

#Preview {
    HomeView()
}
