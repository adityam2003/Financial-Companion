//
//  ContentView.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 05/04/26.
//

import SwiftUI

/// Root view — TabView with Home and Transactions tabs.
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle.fill")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
        }
        .tint(Color(hex: "6366F1"))
    }
}

#Preview {
    ContentView()
}
