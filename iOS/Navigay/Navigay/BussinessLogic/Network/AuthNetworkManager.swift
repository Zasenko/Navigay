//
//  AuthNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum AuthEndPoints {
    case login
    case registration
    case logout
    case deleteAccount
    case resetPassword
}

extension AuthEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .login:
            return "/api/auth/login.php"
        case .registration:
            return "/api/auth/registration.php"
        case .logout:
            return "/api/auth/logout.php"
        case .deleteAccount:
            return "/api/auth/delete-user.php"
        case .resetPassword:
            return "/api/auth/reset-password.php"
        }
    }
}

protocol AuthNetworkManagerProtocol {
    func login(email: String, password: String) async throws -> DecodedAppUser
    func registration(email: String, password: String) async throws -> DecodedAppUser
    func logout(for user: AppUser) async throws
    func deleteAccount(for user: AppUser) async throws
    func resetPassword(email: String) async throws
}

final class AuthNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AuthNetworkManager: AuthNetworkManagerProtocol {
    
    func resetPassword(email: String) async throws {
        debugPrint("--- resetPassword(email: \(email)")
        let parameters = [
            "email": email
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoints.resetPassword, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func logout(for user: AppUser) async throws {
        debugPrint("--- logout()")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]        
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoints.logout, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func registration(email: String, password: String) async throws -> DecodedAppUser {
        debugPrint("--- registration()")
        let parameters = [
            "email": email,
            "password": password
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoints.registration, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AuthResult.self, with: request)
        guard decodedResult.result, let decodedAppUser = decodedResult.user else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedAppUser
    }
    
    func login(email: String, password: String) async throws -> DecodedAppUser {
        debugPrint("--- login()")
        let parameters = [
            "email": email,
            "password": password,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoints.login, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AuthResult.self, with: request)
        guard decodedResult.result, let decodedAppUser = decodedResult.user else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedAppUser
    }
    
    func deleteAccount(for user: AppUser) async throws {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoints.deleteAccount, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}
