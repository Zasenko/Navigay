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
    
    var sharedModelContainer: ModelContainer = {
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
    
    let appSettingsManager: AppSettingsManagerProtocol
    let errorManager: ErrorManagerProtocol
    let keychainManager: KeychainManagerProtocol
    
    init() {
        let appSettingsManager = AppSettingsManager()
        let errorManager = ErrorManager()
        let keychainManager = KeychainManager()
        let authNetworkManager = AuthNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager)
        
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
        self.keychainManager = keychainManager
       
    }

    var body: some Scene {
        WindowGroup {
            EntryView(authenticationManager: AuthenticationManager(keychainManager: keychainManager, networkManager: AuthNetworkManager(appSettingsManager: appSettingsManager, errorManager: errorManager), errorManager: errorManager), appSettingsManager: appSettingsManager, errorManager: errorManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
