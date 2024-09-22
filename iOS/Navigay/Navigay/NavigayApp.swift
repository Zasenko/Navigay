//
//  NavigayApp.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

@main
struct NavigayApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
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
            EntryView()
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .background {
                try? sharedModelContainer.mainContext.save()
            }
        }
    }
}
