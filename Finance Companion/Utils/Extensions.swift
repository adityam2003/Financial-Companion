//
//  Extensions.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - Double Formatting

extension Double {

    /// Formats as Indian Rupee currency:  ₹85,000
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "₹0"
    }

    /// Short format for chart labels: 1.2K, 850
    var shortFormatted: String {
        if self >= 1_000 {
            let k = self / 1_000
            return String(format: "%.1fK", k)
        }
        return String(format: "%.0f", self)
    }
}

// MARK: - Color Hex Initializer

extension Color {
    /// Creates a Color from a hex string (e.g. "FF6B6B").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 6: // RGB
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double( int        & 0xFF) / 255,
                1
            )
        case 8: // ARGB
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8)  & 0xFF) / 255,
                Double( int        & 0xFF) / 255,
                Double((int >> 24) & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0, 0, 0, 1)
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
