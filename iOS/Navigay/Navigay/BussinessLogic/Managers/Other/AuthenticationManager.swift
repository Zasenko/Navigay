//
//  AuthenticationManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

enum UserAuthorizationStatus {
    case authorized
    case notAuthorized
    case loading
}

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
    @Published var sessionKey: String? = nil
    
    // MARK: - Private Properties
    
    private let errorManager: ErrorManagerProtocol
    private let keychainManager: KeychainManagerProtocol
    private let networkManager: AuthNetworkManagerProtocol
    
    // MARK: - Inits
    
    init(keychainManager: KeychainManagerProtocol,
         networkManager: AuthNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol) {
        self.keychainManager = keychainManager
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension AuthenticationManager {
    
    // MARK: - Functions
    
    func authentificate(user: AppUser) {
        appUser = user
        Task {
            do {
                let password = try keychainManager.getGenericPasswordFor(account: user.email, service: "User login")
                guard let decodedAppUser = await networkManager.login(email: user.email, password: password) else {
                    return
                }
                
                await MainActor.run {
                    user.updateUser(decodedUser: decodedAppUser)
                    user.isUserLoggedIn = true
                    sessionKey = decodedAppUser.sessionKey
                }
                
            } catch {
                debugPrint(error)
                let errorModel = ErrorModel(massage: "Something went wrong. You are not logged in.", img: nil, color: nil)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            }
        }
    }
    
    func registration(email: String, password: String) async -> AppUser? {
        guard let decodedAppUser = await networkManager.registration(email: email, password: password) else {
            return nil
        }
        
        do {
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
        } catch {
            debugPrint(error)
            let errorModel = ErrorModel(massage: "Something went wrong. You are not registration.", img: nil, color: nil)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            return nil
        }
        
        let user = AppUser(decodedUser: decodedAppUser)
        
        await MainActor.run {
            lastLoginnedUserId = user.id
            sessionKey = decodedAppUser.sessionKey
            user.isUserLoggedIn = true
            appUser = user
        }
        return user
    }
    
    func login(email: String, password: String) async -> DecodedAppUser? {
        
        guard let decodedAppUser = await networkManager.login(email: email, password: password) else {
            return nil
        }
        
        do {
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
        }  catch {
            debugPrint(error)
            let errorModel = ErrorModel(massage: "Something went wrong. You are not logged in.", img: nil, color: nil)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            return nil
        }
        
        await MainActor.run {
            lastLoginnedUserId = decodedAppUser.id
            sessionKey = decodedAppUser.sessionKey
        }
        return decodedAppUser
    }
}
//    func checkEmail(email: String) {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        if !emailPred.evaluate(with: email) {
//            errorManager.showError(with: ErrorModel(id: UUID(), massage: "Неверный формат электронной почты.", img: Image(systemName: "at"), color: .red))
//        }
//    }
    
//    func checkPassword(password: String) {
//        if password.count < 8 {
//            errorManager.showError(with: ErrorModel(id: UUID(), massage: "Пароль должен быть не менее 8 символов.", img: Image(systemName: "lock"), color: .red))
//        } else if (!NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: password)) {
//            errorManager.showError(with: ErrorModel(id: UUID(), massage: "Пароль должен содержать хотя бы одну цифру.", img: Image(systemName: "lock"), color: .red))
//        } else if (!NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: password)) {
//            errorManager.showError(with: ErrorModel(id: UUID(), massage: "Пароль должен содержать как минимум одну букву.", img: Image(systemName: "lock"), color: .red))
//        }
//    }


//extension AuthenticationManager {
//    
//    // MARK: - Private Functions
//    
//    private func checkEmailAndPassword(email: String, password: String) async throws {
//        if email.isEmpty {
//            throw AuthManagerErrors.emptyEmail
//        }
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        if !emailPred.evaluate(with: email) {
//            throw AuthManagerErrors.wrongEmail
//        } else if password.isEmpty {
//            throw AuthManagerErrors.emptyPassword
//        } else if password.count < 8 {
//            throw AuthManagerErrors.noMinCharacters
//        } else if(!NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: password)){
//            throw AuthManagerErrors.noDigit
//        } else if(!NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: password)){
//            throw AuthManagerErrors.noLowercase
//        }
//    }
//}
