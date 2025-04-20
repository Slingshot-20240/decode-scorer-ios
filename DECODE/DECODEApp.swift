//
//  DECODEApp.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import SwiftUI
import SwiftData

@main
struct DECODEApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameDataWrapper.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
