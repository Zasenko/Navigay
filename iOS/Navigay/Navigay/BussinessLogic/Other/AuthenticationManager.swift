//
//  AuthenticationManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

enum AuthManagerErrors: Error {
    case emptyEmail
    case emptyPassword
    case noUppercase
    case noDigit
    case noLowercase
    case noMinCharacters
    case wrongEmail
}

final class AuthenticationManager: ObservableObject {
    
    // MARK: - Properties
    
    @AppStorage("lastLoginnedUserId") var lastLoginnedUserId: Int = 0
    @Published var appUser: AppUser? = nil
    @Published var isUserOnline: Bool = false
    
    let errorManager: ErrorManagerProtocol
    let authNetworkManager: AuthNetworkManagerProtocol
    
    let networkManager: NetworkManagerProtocol
    
    // MARK: - Private Properties
    
    private var networkMonitorManager: NetworkMonitorManagerProtocol
    private let keychainManager: KeychainManagerProtocol
    
    // MARK: - Init
    
    init(keychainManager: KeychainManagerProtocol,
         networkMonitorManager: NetworkMonitorManagerProtocol,
         networkManager: NetworkManagerProtocol,
         authNetworkManager: AuthNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol) {
        self.keychainManager = keychainManager
        self.networkMonitorManager = networkMonitorManager
        self.networkManager = networkManager
        self.authNetworkManager = authNetworkManager
        self.errorManager = errorManager
    }
}

extension AuthenticationManager {
    
    // MARK: - Functions
    
    func authentificate(user: AppUser) {
        appUser = user
        if networkMonitorManager.isConnected {
            auth(user: user)
        } else {
            networkMonitorManager.notify = { [weak self] result in
                guard let self = self else {return}
                if result, !self.isUserOnline {
                    self.auth(user: user)
                }
            }
        }
    }
    
    func logOut(user: AppUser) {
        user.isUserLoggedIn = false
        appUser = nil
        Task {
            try? await authNetworkManager.logout(for: user)
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        do {
            try await authNetworkManager.resetPassword(email: email)
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
        } catch {
            errorManager.showErrorMessage(error: error)
        }
        return false
    }
    
    private func auth(user: AppUser) {
        Task {
            let message = "Oops! Something went wrong. You're not logged in. Please try again later."
            do {
                let password = try keychainManager.getGenericPasswordFor(account: user.email, service: "User login")
                let decodedAppUser = try await authNetworkManager.login(email: user.email, password: password)
                await MainActor.run {
                    user.updateUser(decodedUser: decodedAppUser)
                    isUserOnline = true
                }
                return
            } catch NetworkErrors.noConnection {
                errorManager.showError(model: ErrorModel(error: NetworkErrors.noConnection, message: "You're not logged in.", img: AppImages.iconPersonError, color: nil))
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: NetworkErrors.noConnection, message: message, img: AppImages.iconPersonError, color: nil))
            }
            await MainActor.run {
                isUserOnline = false
            }
        }
    }
    
    @MainActor
    func registration(email: String, password: String) async throws -> AppUser {
        let decodedAppUser = try await authNetworkManager.registration(email: email,
                                                                   password: password)
        try keychainManager.storeGenericPasswordFor(account: email,
                                                    service: "User login",
                                                    password: password)
        let user = AppUser(decodedUser: decodedAppUser)
        user.isUserLoggedIn = true
        lastLoginnedUserId = user.id
        appUser = user
        isUserOnline = true
        return user
    }
    
    @MainActor
    func login(email: String, password: String) async throws -> DecodedAppUser {
        let decodedAppUser = try await authNetworkManager.login(email: email,
                                                            password: password)
        try keychainManager.storeGenericPasswordFor(account: email,
                                                    service: "User login",
                                                    password: password)
        lastLoginnedUserId = decodedAppUser.id
        return decodedAppUser
    }
    
    func deleteAccount(user: AppUser) async -> Bool {
        do {
            try await authNetworkManager.deleteAccount(for: user)
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showUpdateError(error: error)
        }
        return false
    }
}
