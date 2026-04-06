//
//  WeeklyChartView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - WeeklyChartView

/// A comparison bar chart showing current vs previous week spending per day.
/// Built with pure SwiftUI — no Charts framework dependency.
///
/// Color logic:
/// - First 5 days (new user): all bars are uniform indigo (not enough data to compare)
/// - After 5 days: bars are intensity-colored (red/amber/indigo) relative to the week's max
struct WeeklyChartView: View {

    let data: [DailySpending]
    let insight: String
    let isPositiveTrend: Bool
    let hasEnoughHistory: Bool    // drives intensity coloring vs flat blue

    /// Highest value across both weeks — used to normalize heights.
    private var maxAmount: Double {
        let allValues = data.flatMap { [$0.amount, $0.previousAmount] }
        return allValues.max() ?? 1
    }

    @State private var appeared = false
    @State private var showInfoPopover = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Row 1: Title + info icon
            HStack(alignment: .center, spacing: 6) {
                Label("Weekly Spending", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Info button explaining color system
                Button {
                    showInfoPopover.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .popover(isPresented: $showInfoPopover, arrowEdge: .top) {
                    infoPopoverContent
                }

                Spacer()
            }

            // Row 2: Legend tags — ALL on one line below header
            HStack(spacing: 12) {
                if hasEnoughHistory {
                    legendDot(color: Color(hex: "EE5A24"), label: "High")
                    legendDot(color: Color(hex: "FF9F43"), label: "Mid")
                    legendDot(color: Color(hex: "6366F1"), label: "Low")
                } else {
                    legendDot(color: Color(hex: "6366F1"), label: "This week")
                }

                // Separator
                Text("·")
                    .foregroundStyle(.quaternary)

                legendDot(color: Color.gray.opacity(0.45), label: "Last week")
            }
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)

            // Row 3: Dynamic insight chip (only when enough history)
            if hasEnoughHistory {
                insightChip
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 10, weight: .bold))

                    Text("Tracking your first week — insights unlock in a few days")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundStyle(Color(hex: "6366F1"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(hex: "6366F1").opacity(0.08))
                .clipShape(Capsule())
            }

            // Bar chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { item in
                    VStack(spacing: 6) {
                        // Amount label (only for non-zero current)
                        if item.amount > 0 {
                            Text(item.amount.shortFormatted)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        } else {
                            Text(" ")
                                .font(.system(size: 10))
                        }

                        // Paired bars
                        HStack(alignment: .bottom, spacing: 3) {
                            // Previous week bar (ghost)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.gray.opacity(0.35))
                                .frame(width: 12, height: appeared ? barHeight(for: item.previousAmount) : 4)

                            // Current week bar
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(barGradient(for: item.amount))
                                .frame(width: 12, height: appeared ? barHeight(for: item.amount) : 4)
                        }

                        // Day label
                        Text(item.day)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }

    // MARK: - Insight Chip

    private var insightChip: some View {
        HStack(spacing: 4) {
            Image(systemName: isPositiveTrend ? "arrow.down.right" : "arrow.up.right")
                .font(.system(size: 10, weight: .bold))

            Text(insight)
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .foregroundStyle(isPositiveTrend ? Color(hex: "10B981") : Color(hex: "EF4444"))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            (isPositiveTrend ? Color(hex: "10B981") : Color(hex: "EF4444"))
                .opacity(0.12)
        )
        .clipShape(Capsule())
    }

    // MARK: - Info Popover

    private var infoPopoverContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How colors work")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 8) {
                infoRow(color: Color(hex: "6366F1"),
                        text: "First 5 days — all bars are blue while we learn your patterns")
                infoRow(color: Color(hex: "EE5A24"),
                        text: "High — top 25% of your weekly spending")
                infoRow(color: Color(hex: "FF9F43"),
                        text: "Mid — moderate spending day")
                infoRow(color: Color(hex: "6366F1"),
                        text: "Low — below 40% of your peak day")
                infoRow(color: Color.gray.opacity(0.45),
                        text: "Gray — same day last week for comparison")
            }

            Text("Colors are relative to your own spending — not fixed thresholds.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 280)
        .presentationCompactAdaptation(.popover)
    }

    private func infoRow(color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 4)

            Text(text)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Helpers

    private func barHeight(for amount: Double) -> CGFloat {
        guard maxAmount > 0 else { return 4 }
        let ratio = amount / maxAmount
        return max(CGFloat(ratio) * 110, 4)
    }

    /// Smart gradient:
    /// - Not enough history → uniform indigo (new user, first 5 days)
    /// - Enough history → intensity-based (red > amber > indigo)
    private func barGradient(for amount: Double) -> LinearGradient {
        guard hasEnoughHistory else {
            // New user — flat indigo for all bars
            return LinearGradient(colors: [Color(hex: "818CF8"), Color(hex: "6366F1")],
                                  startPoint: .bottom, endPoint: .top)
        }

        let ratio = maxAmount > 0 ? amount / maxAmount : 0
        if ratio > 0.75 {
            return LinearGradient(colors: [Color(hex: "FF6B6B"), Color(hex: "EE5A24")],
                                  startPoint: .bottom, endPoint: .top)
        } else if ratio > 0.4 {
            return LinearGradient(colors: [Color(hex: "FECA57"), Color(hex: "FF9F43")],
                                  startPoint: .bottom, endPoint: .top)
        } else {
            return LinearGradient(colors: [Color(hex: "818CF8"), Color(hex: "6366F1")],
                                  startPoint: .bottom, endPoint: .top)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }
}

// MARK: - Preview

#Preview("With History") {
    WeeklyChartView(
        data: [
            .init(day: "Mon", amount: 300,  previousAmount: 600),
            .init(day: "Tue", amount: 1000, previousAmount: 1550),
            .init(day: "Wed", amount: 600,  previousAmount: 500),
            .init(day: "Thu", amount: 3100, previousAmount: 2200),
            .init(day: "Fri", amount: 1800, previousAmount: 2000),
            .init(day: "Sat", amount: 4750, previousAmount: 250),
            .init(day: "Sun", amount: 1650, previousAmount: 4150),
        ],
        insight: "Reduced spending by 12% 👏",
        isPositiveTrend: true,
        hasEnoughHistory: true
    )
    .padding()
}

#Preview("New User") {
    WeeklyChartView(
        data: [
            .init(day: "Mon", amount: 300,  previousAmount: 0),
            .init(day: "Tue", amount: 1000, previousAmount: 0),
            .init(day: "Wed", amount: 600,  previousAmount: 0),
        ],
        insight: "",
        isPositiveTrend: true,
        hasEnoughHistory: false
    )
    .padding()
}
