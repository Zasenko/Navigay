//
//  NavigayApp.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData
import GoogleSignIn

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

    var body: some Scene {
        WindowGroup {
            EntryView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                          GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            // Check if `user` exists; otherwise, do something with `error`
                          }
                        }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
