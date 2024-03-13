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
    
    // MARK: - Private Properties
    
    private let keychainManager: KeychainManagerProtocol
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    
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
            await networkManager.logout(id: user.id, sessionKey: sessionKey)
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        do {
            try await networkManager.resetPassword(email: email)
            return true
        } catch NetworkErrors.apiError(let apiError) {
            let errorModel = ErrorModel(massage: "Что-то пошло не так.", img: nil, color: nil)
            errorManager.showApiErrorOrMessage(apiError: apiError, or: errorModel)
            return false
        } catch {
            debugPrint(error.localizedDescription)
            let errorModel = ErrorModel(massage: "Что-то пошло не так.", img: nil, color: nil)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            return false
        }
    }
    
    private func auth(user: AppUser) {
        Task {
            let errorModel = ErrorModel(massage: "Что-то пошло не так, вы не вошли в свой аккаунт.", img: AppImages.iconPersonError, color: .red)
            do {
                let password = try keychainManager.getGenericPasswordFor(account: user.email, service: "User login")
                let decodedAppUser = try await networkManager.login(email: user.email, password: password)
                
                await MainActor.run {
                    user.updateUser(decodedUser: decodedAppUser)
                    user.isUserLoggedIn = true
                }
                
            } catch NetworkErrors.apiError(let apiError) {
                //TODO: обрабоать разные варианты ошибок
                await MainActor.run {
                    user.isUserLoggedIn = false
                }
                errorManager.showApiErrorOrMessage(apiError: apiError, or: errorModel)
            } catch {
                await MainActor.run {
                    user.isUserLoggedIn = false
                }
                debugPrint(error.localizedDescription)
                errorManager.showError(model: errorModel)
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
        do {
            let decodedAppUser = try await networkManager.login(email: email,
                                                                password: password)
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
            lastLoginnedUserId = decodedAppUser.id
            return decodedAppUser
        } catch {
            throw error
        }
    }
    
    func deleteAccount(user: AppUser) async throws {
        do {
            guard let sessionKey = user.sessionKey else {
                throw NetworkErrors.noSessionKey
            }
            try await networkManager.deleteAccount(id: user.id, sessionKey: sessionKey)
        } catch {
            throw error
        }
    }
}
