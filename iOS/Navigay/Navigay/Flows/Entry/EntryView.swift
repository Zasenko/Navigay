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
    
    @Query private var appUsers: [AppUser]
    
    @AppStorage("firstTimeInApp") private var firstTimeInApp: Bool = true
    
    @State private var router: EntryViewRouter = .welcomeView
    @StateObject private var authenticationManager: AuthenticationManager
    
    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private let networkMonitor: NetworkMonitorManagerProtocol
    
    init() {
        let appSettingsManager = AppSettingsManager()
        let errorManager = ErrorManager()
        let keychainManager = KeychainManager()
        let authNetworkManager = AuthNetworkManager(appSettingsManager: appSettingsManager)
        let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkManager: authNetworkManager, errorManager: errorManager)
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
        
        self.networkMonitor = NetworkMonitorManager(errorManager: errorManager)
        
        _authenticationManager = StateObject(wrappedValue: authenticationManager)
        _router = State(wrappedValue: EntryViewRouter.welcomeView)
        let id = authenticationManager.lastLoginnedUserId
        if id != 0 {
            _appUsers = Query(filter: #Predicate<AppUser>{ $0.id == id })
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch router {
            case .welcomeView:
                WelcomeView(authenticationManager: authenticationManager) {
                    firstTimeInApp = false
                        router = .tabView
                }
            case .tabView:
                TabBarView(authenticationManager: authenticationManager, appSettingsManager: appSettingsManager, errorManager: errorManager)
            }
            ErrorView(viewModel: ErrorViewModel(errorManager: errorManager))
        }
        .onAppear() {
            if firstTimeInApp {
                router = .welcomeView
            } else {
                router = .tabView
                if let appUser = appUsers.first(where: { $0.id == authenticationManager.lastLoginnedUserId }),
                   appUser.isUserLoggedIn {
                    authenticationManager.authentificate(user: appUser)
                }
            }
        }
    }
}

#Preview {
    EntryView()
}
