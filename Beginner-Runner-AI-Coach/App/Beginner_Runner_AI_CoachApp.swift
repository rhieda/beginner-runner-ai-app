//
//  Beginner_Runner_AI_CoachApp.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import SwiftUI
import SwiftData
import HealthKit

@main
struct BeginnerRunnerAICoachApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                .task {
                    try? await start()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    func start() async throws {
        let datasource = HKHealthStore()
        let fetcher = StepsDataProvider(healthStore: datasource)
        let data = try await fetcher
            .requestAuthorization()
            .requestData(
                from: Date.distantPast,
                to: .now
            )
        dump(data)
    }
}

