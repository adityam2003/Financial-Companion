//
//  InsightsView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import SwiftUI

struct InsightsView: View {
    @State private var viewModel = InsightsViewModel()
    @State private var isGeneratingPDF = false
    var onAddTransaction: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Time Range Picker
                    Picker("Time Range", selection: $viewModel.timeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content Section
                    if viewModel.hasNoTransactions {
                        emptySummarySection
                            .padding(.horizontal)
                        
                        emptyInsightsSection
                            .padding(.horizontal)
                    } else {
                        // Summary Section
                        summarySection
                            .padding(.horizontal)
                        
                        // Key Insights
                        if !viewModel.insightCards.isEmpty {
                            insightsSection
                                .padding(.horizontal)
                        }
                        
                        // Budget Alerts
                        if !viewModel.budgetAlerts.isEmpty {
                            budgetAlertsSection
                                .padding(.horizontal)
                        }
                        
                        // Category Breakdown
                        if !viewModel.categoryBreakdowns.isEmpty {
                            categoryBreakdownSection
                                .padding(.horizontal)
                        }
                    }
                    
                    // Empty state buffer
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isGeneratingPDF = true
                        DispatchQueue.global(qos: .userInitiated).async {
                            if let url = PDFReportGenerator.generateInsightsPDF(viewModel: viewModel) {
                                DispatchQueue.main.async {
                                    self.isGeneratingPDF = false
                                    presentShareSheet(url: url)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.isGeneratingPDF = false
                                }
                            }
                        }
                    }) {
                        if isGeneratingPDF {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .disabled(isGeneratingPDF || viewModel.hasNoTransactions)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var emptySummarySection: some View {
        VStack(spacing: 16) {
            Text("No spending tracked yet 👀")
                .font(.headline)
            
            Text("Start adding expenses to unlock insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Text("+ Add Transaction")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var emptyInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Insights")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "6366F1"))
                    .padding(.bottom, 4)
                
                Text("Your insights will appear here")
                    .font(.headline)
                
                Text("Track a few expenses to discover patterns in your spending")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    emptyInsightRow(icon: "chart.pie.fill", color: .purple, text: "See your top spending category")
                    emptyInsightRow(icon: "calendar.badge.exclamationmark", color: .orange, text: "Find your highest spending day")
                    emptyInsightRow(icon: "chart.line.uptrend.xyaxis", color: .green, text: "Track weekly trends")
                }
                .padding(.top, 16)
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private func emptyInsightRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Populated Sections
    
    private var summarySection: some View {
        VStack(spacing: 8) {
            Text(viewModel.timeRange == .thisWeek ? "Spent this week" : "Spent this month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.formattedTotalSpent)
                .font(.system(size: 40, weight: .bold, design: .rounded))
            
            Text(viewModel.trendText)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(viewModel.percentageChange > 0 ? Color.red : (viewModel.percentageChange < 0 ? Color.green : Color.secondary))
            
            SparklineView(data: viewModel.sparklineData, lineColor: viewModel.percentageChange > 0 ? .red : (viewModel.percentageChange < 0 ? .green : .blue))
                .frame(height: 48)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Insights")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(viewModel.insightCards) { card in
                    HStack(spacing: 16) {
                        Image(systemName: card.iconName)
                            .font(.title3)
                            .foregroundStyle(card.iconColor)
                            .frame(width: 44, height: 44)
                            .background(card.iconColor.opacity(0.15))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.headline)
                                .font(.headline)
                            Text(card.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }
    
    private var budgetAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Budget Alerts")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.budgetAlerts, id: \.self) { alert in
                    HStack(spacing: 12) {
                        let isExceeded = alert.contains("exceeded")
                        Image(systemName: isExceeded ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(isExceeded ? Color.red : Color.orange)
                        
                        Text(alert)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fontWeight(isExceeded ? .semibold : .regular)
                        Spacer()
                    }
                    if alert != viewModel.budgetAlerts.last {
                        Divider()
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 24) {
                if let topHighlight = viewModel.topCategoryHighlight {
                    Text(topHighlight)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                DonutChartView(slices: viewModel.categoryBreakdowns.map { DonutSlice(percentage: $0.percentage, color: $0.category.rawColor) })
                    .frame(height: 180)
                    .padding(.vertical, 8)
                
                VStack(spacing: 20) {
                    ForEach(viewModel.categoryBreakdowns) { breakdown in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label {
                                    Text(breakdown.category.rawValue)
                                        .foregroundStyle(Color.primary)
                                } icon: {
                                    Image(systemName: breakdown.category.iconName)
                                        .foregroundStyle(breakdown.category.rawColor)
                                }
                                .font(.subheadline)
                                Spacer()
                                Text(viewModel.currencyFormatter.string(from: NSNumber(value: breakdown.amount)) ?? "₹0")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(breakdown.category.rawColor)
                                        .frame(width: max(0, geo.size.width * breakdown.percentage), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    InsightsView()
}
