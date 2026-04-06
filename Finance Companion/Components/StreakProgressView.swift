//
//  StreakProgressView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - StreakProgressView

/// Circular progress indicator showing the user's no-spend streak.
/// Goal is fixed at 7 days for a visual target.
struct StreakProgressView: View {

    let streakDays: Int
    let streakMessage: String   // Provided by ViewModel — no logic here
    
    private var currentGoal: Int {
        if streakDays < 7 { return 7 }
        if streakDays < 14 { return 14 }
        if streakDays < 30 { return 30 }
        if streakDays < 50 { return 50 }
        if streakDays < 100 { return 100 }
        return ((streakDays / 100) + 1) * 100
    }

    /// Progress ratio clamped to 0…1
    private var progress: Double {
        if streakDays == 0 { return 0 }
        return min(Double(streakDays) / Double(currentGoal), 1.0)
    }

    @State private var animatedProgress: Double = 0
    @State private var showContent = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Label("No-Spend Streak", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                // Circular progress ring
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 10)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            AngularGradient(
                                colors: [Color(hex: "F97316"), Color(hex: "EF4444"), Color(hex: "F97316")],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    // Center icon & count
                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .symbolEffect(.pulse, options: .repeating, value: streakDays > 0)

                        Text("\(streakDays)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("days")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 90, height: 90)

                // Text details
                VStack(alignment: .leading, spacing: 6) {
                    Text(streakMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 8)

                    Text("\(streakDays) of \(currentGoal) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * animatedProgress)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StreakProgressView(streakDays: 0, streakMessage: "Start your streak today!")
        StreakProgressView(streakDays: 4, streakMessage: "🔥 4 day streak! Almost there!")
        StreakProgressView(streakDays: 7, streakMessage: "🔥 7 day streak! You're a legend! 🏆")
    }
    .padding()
}
