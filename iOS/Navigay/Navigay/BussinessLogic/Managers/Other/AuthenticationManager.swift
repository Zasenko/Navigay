//
//  AuthenticationManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

//enum UserAuthorizationStatus {
//    case authorized
//    case notAuthorized
//    case loading
//}

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
    
    //   @Published var userAuthorizationStatus: UserAuthorizationStatus = .loading
    @Published var appUser: AppUser? = nil
    
    let errorManager: ErrorManagerProtocol
    let networkManager: AuthNetworkManagerProtocol
    let networkMonitorManager: NetworkMonitorManagerProtocol
    
    // MARK: - Private Properties
    
    private let keychainManager: KeychainManagerProtocol
    
    // MARK: - Init
    
    init(keychainManager: KeychainManagerProtocol,
         networkMonitorManager: NetworkMonitorManagerProtocol,
         networkManager: AuthNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol) {
        self.keychainManager = keychainManager
        self.networkMonitorManager = networkMonitorManager
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension AuthenticationManager {
    
    // MARK: - Functions
    
    func authentificate(user: AppUser) {
        appUser = user
        guard networkMonitorManager.isConnected else {
            //следим за обновлением networkMonitorManager.isConnected и когда оно подключится - делаем логин
            return
        }
        auth(user: user)
    }
    
    func logOut(user: AppUser) {
        user.isUserLoggedIn = false
        appUser = nil
        Task {
            guard let sessionKey = user.sessionKey else { return }
            try await networkManager.logout(for: user)
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        let message = ""
        do {
            try await networkManager.resetPassword(email: email)
            return true
        } catch NetworkErrors.noConnection {
            errorManager.showNetworkNoConnected()
        } catch NetworkErrors.apiError(let apiError) {
            errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
        } catch {
            errorManager.showErrorMassage(error: error)
        }
        return false
    }
    
    private func auth(user: AppUser) {
        Task {
            let message = "Oops! Something went wrong. You're not logged in. Please try again later."
            
            do {
                let password = try keychainManager.getGenericPasswordFor(account: user.email, service: "User login")
                let decodedAppUser = try await networkManager.login(email: user.email, password: password)
                await MainActor.run {
                    user.updateUser(decodedUser: decodedAppUser)
                    user.isUserLoggedIn = true
                }
                return
                
            }  catch NetworkErrors.noConnection {
                errorManager.showError(model: ErrorModel(error: NetworkErrors.noConnection, massage: "You're not logged in.", img: AppImages.iconPersonError, color: nil))
                
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: NetworkErrors.noConnection, massage: message, img: AppImages.iconPersonError, color: nil))
            }
            await MainActor.run {
                user.isUserLoggedIn = false
            }
        }
    }
    
    @MainActor
    func registration(email: String, password: String) async throws -> AppUser {
        do {
            let decodedAppUser = try await networkManager.registration(email: email,
                                                                       password: password)
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
            let user = AppUser(decodedUser: decodedAppUser)
            user.isUserLoggedIn = true
            lastLoginnedUserId = user.id
            appUser = user
            return user
        } catch {
            throw error
        }
    }
    
    @MainActor
    func login(email: String, password: String) async throws -> DecodedAppUser {
            let decodedAppUser = try await networkManager.login(email: email,
                                                                password: password)
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
            lastLoginnedUserId = decodedAppUser.id
            return decodedAppUser
    }
    
    func deleteAccount(user: AppUser) async throws -> Bool {
        do {
            try await networkManager.deleteAccount(for: user)
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
