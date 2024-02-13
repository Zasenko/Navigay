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
    
    @StateObject var authenticationManager: AuthenticationManager
    let appSettingsManager: AppSettingsManagerProtocol
    let errorManager: ErrorManagerProtocol
    
    // MARK: - private Properties
    
    @AppStorage("firstTimeInApp") private var firstTimeInApp: Bool = true
    @Query private var appUsers: [AppUser]
    @State private var router: EntryViewRouter = .welcomeView
    
    
    
    var body: some View {
        ZStack(alignment: .top) {
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
                if authenticationManager.lastLoginnedUserId != 0,
                   let appUser = appUsers.first(where: { $0.id == authenticationManager.lastLoginnedUserId }),
                   appUser.isUserLoggedIn {
                    authenticationManager.authentificate(user: appUser)
                }
            }
        }
    }
}
//
//#Preview {
//    EntryView()
//}
