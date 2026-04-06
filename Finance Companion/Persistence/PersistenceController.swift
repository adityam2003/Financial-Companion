//
//  PersistenceController.swift
//  Finance Companion
//
//  Created by Aditya Mathur on 06/04/26.
//

import Foundation
import SwiftData

// MARK: - PersistenceController

/// Owns the SwiftData ModelContainer for the entire app.
/// All stores read/write through `shared.modelContext` (which maps to the main actor context).
final class PersistenceController {

    // MARK: - Singleton

    static let shared = PersistenceController()

    // MARK: - Container

    let container: ModelContainer

    /// Shortcut to the container's main-actor context.
    var modelContext: ModelContext { container.mainContext }

    // MARK: - Init

    private init(inMemory: Bool = false) {
        let schema = Schema([Transaction.self, Budget.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
    }

    // MARK: - Preview Support

    /// In-memory container for SwiftUI Previews — data is discarded when the preview closes.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        MockDataService.seedIfNeeded(context: controller.modelContext, force: true)
        return controller
    }()
}
