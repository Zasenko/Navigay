//
//  EntryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

enum EntryViewRouter {
    case tabView
    case welcomeView
}

struct EntryView: View {
    
    // MARK: - Private Properties
    
    @Query private var appUsers: [AppUser]
    @AppStorage("firstTimeInApp") private var firstTimeInApp: Bool = true
    @State private var router: EntryViewRouter = .welcomeView
    @StateObject private var authenticationManager: AuthenticationManager
    
    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let networkMonitor: NetworkMonitorManagerProtocol
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Init
    
    init() {
        let appSettingsManager = AppSettingsManager()
        let errorManager = ErrorManager()
        let keychainManager = KeychainManager()
        let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
        let networkManager = NetworkManager(session: URLSession(configuration: .default), networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager, keychainManager: keychainManager)
        let authNetworkManager = AuthNetworkManager(networkManager: networkManager)
        let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, authNetworkManager: authNetworkManager, errorManager: errorManager)
        self.networkMonitor = networkMonitorManager
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
        self.networkManager = networkManager
        _authenticationManager = StateObject(wrappedValue: authenticationManager)
        _router = State(wrappedValue: EntryViewRouter.welcomeView)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            switch router {
            case .welcomeView:
                WelcomeView {
                    firstTimeInApp = false
                    router = .tabView
                }
            case .tabView:
                TabBarView(errorManager: errorManager, networkManager: networkManager)
            }
            ErrorView(viewModel: ErrorViewModel(errorManager: errorManager), moveFrom: .bottom, alignment: .bottom)
        }
        .onAppear() {
            setRouter()
        }
        .environmentObject(authenticationManager)
    }
    
    // MARK: - Private Functions
    
    private func setRouter() {
        if firstTimeInApp {
            router = .welcomeView
        } else {
            router = .tabView
            authentificate()
        }
    }
    
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
