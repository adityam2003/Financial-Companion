//
//  SectionHeaderView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

// MARK: - SectionHeaderView

/// Reusable section header with optional trailing action button.
struct SectionHeaderView: View {

    let title: String
    let icon: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(hex: "6366F1"))
                }
            }
        }
    }
}

#Preview {
    SectionHeaderView(title: "Recent", icon: "clock.fill", actionTitle: "See All") {}
        .padding()
}
