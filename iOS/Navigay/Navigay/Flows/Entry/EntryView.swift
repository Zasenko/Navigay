//
//  EntryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

struct EntryView: View {
    
    // MARK: - Private Properties
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("firstTimeInApp") private var firstTimeInApp: Bool = true
    @Query private var appUsers: [AppUser]
    @StateObject private var authenticationManager: AuthenticationManager
    private let errorManager: ErrorManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private let notificationsManager: NotificationsManagerProtocol
    
    // MARK: - Init
    
    init() {
        let appSettingsManager = AppSettingsManager()
        let errorManager = ErrorManager()
        let keychainManager = KeychainManager()
        let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
        let networkManager = NetworkManager(session: URLSession(configuration: .default), networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
        let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
        let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
        self.errorManager = errorManager
        self.networkManager = networkManager
        self.notificationsManager = NotificationsManager()
        _authenticationManager = StateObject(wrappedValue: authenticationManager)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if firstTimeInApp {
                WelcomeView(firstTimeInApp: $firstTimeInApp)
            } else {
                TabBarView(errorManager: errorManager, networkManager: networkManager, notificationsManager: notificationsManager)
                    .onAppear {
                        authentificate()
                    }
            }
            ErrorView(viewModel: ErrorViewModel(errorManager: errorManager), moveFrom: .top, alignment: .top)
        }
        .environmentObject(authenticationManager)
    }
    
    // MARK: - Private Functions
    
    private func authentificate() {
        guard let appUser = appUsers.first(where: { $0.id == authenticationManager.lastLoginnedUserId }),
              appUser.isUserLoggedIn else {
            return
        }
        authenticationManager.authentificate(user: appUser)
    }
}

#Preview {
    EntryView()
}
