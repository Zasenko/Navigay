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
    
 //   @Published var userAuthorizationStatus: UserAuthorizationStatus = .loading
    @Published var appUser: AppUser? = nil
    let errorManager: ErrorManagerProtocol
    
    // MARK: - Private Properties
    
    private let keychainManager: KeychainManagerProtocol
    let networkManager: AuthNetworkManagerProtocol
    
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
                let result = try await networkManager.login(email: user.email, password: password)
                
                await MainActor.run {
                    
                    guard result.result,
                          let decodedUser = result.user
                    else {
                        errorManager.showApiError(error: result.error)
                        
                        user.isUserLoggedIn = false
                        // userAccessRights = .anonim
                        //userAuthorizationStatus = .notAuthorized
                        return
                    }
                    user.updateUser(decodedUser: decodedUser)
                    user.isUserLoggedIn = true
                 //   self.userAuthorizationStatus = .authorized
                }
                
            } catch {
                errorManager.showError(error: error)
            }
        }
    }
    
    @MainActor
    func registration(email: String, password: String) async -> AppUser? {
        do {
            let result = try await networkManager.registration(email: email, password: password)
            guard result.result,
                  let decodedUser = result.user
            else  {
                errorManager.showApiError(error: result.error)
                
                return nil
            }
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
            let user = AppUser(decodedUser: decodedUser)
            user.isUserLoggedIn = true
            lastLoginnedUserId = user.id
            appUser = user
            return user
        } catch {
            errorManager.showError(error: error)
            return nil
        }
    }
    
    @MainActor
    func login(email: String, password: String) async -> DecodedAppUser? {
        do {
            let result = try await networkManager.login(email: email, password: password)
            guard result.result,
                  let decodedUser = result.user
            else  {
                errorManager.showApiError(error: result.error)
                return nil
            }
            try keychainManager.storeGenericPasswordFor(account: email,
                                                        service: "User login",
                                                        password: password)
            lastLoginnedUserId = decodedUser.id
            return decodedUser
        } catch {
            errorManager.showError(error: error)
            return nil
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
}


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
