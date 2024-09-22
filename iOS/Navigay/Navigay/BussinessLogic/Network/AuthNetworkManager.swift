//
//  AuthNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

enum AuthEndPoint {
    case login
    case registration
    case logout
    case deleteAccount
    case resetPassword
}

extension AuthEndPoint: EndPoint {
    
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
        let request = try await networkManager.request(endpoint: AuthEndPoint.resetPassword, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func logout(for user: AppUser) async throws {
        debugPrint("--- logout()")
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "user_id": String(user.id),
            "session_key": tocken,
        ]        
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoint.logout, method: .post, headers: headers, body: body)
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
        let request = try await networkManager.request(endpoint: AuthEndPoint.registration, method: .post, headers: headers, body: body)
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
        let request = try await networkManager.request(endpoint: AuthEndPoint.login, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AuthResult.self, with: request)
        guard decodedResult.result, let decodedAppUser = decodedResult.user else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedAppUser
    }
    
    func deleteAccount(for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AuthEndPoint.deleteAccount, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}
