//
//  AuthNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

protocol AuthNetworkManagerProtocol {
    func login(email: String, password: String) async throws -> DecodedAppUser
    func registration(email: String, password: String) async throws -> DecodedAppUser
    func logout(id: Int, sessionKey: String) async
    func deleteAccount(id: Int, sessionKey: String) async throws
}

final class AuthNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    private let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
    }

}

// MARK: - AuthNetworkManagerProtocol

extension AuthNetworkManager: AuthNetworkManagerProtocol {
    
    func logout(id: Int, sessionKey: String) async {
        do {
            guard networkMonitorManager.isConnected else {
                throw NetworkErrors.noConnection
            }
            let path = "/api/auth/logout.php"
            var urlComponents: URLComponents {
                var components = URLComponents()
                components.scheme = scheme
                components.host = host
                components.path = path
                return components
            }
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "user_id": String(id),
                "session_key": sessionKey,
            ]
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                debugPrint("-API ERROR- UserNetworkManager updateUserName user id \(id) : ", decodedResult.error?.message ?? "")
                return
            }
        } catch {
            debugPrint("-ERROR- UserNetworkManager updateUserName user id \(id) : ", error)
        }
    }
    
    
    func registration(email: String, password: String) async throws -> DecodedAppUser {
        debugPrint("--- registration()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/auth/registration.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        let parameters = [
            "email": email,
            "password": password,
            "language": appSettingsManager.language
        ]
        do {
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
           // let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
          //  print(json)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AuthResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedAppUser = decodedResult.user else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
            return decodedAppUser
        } catch {
            throw error
        }
    }
    
    func login(email: String, password: String) async throws -> DecodedAppUser {
        debugPrint("--- login()")
        let path = "/api/auth/login.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        let parameters = [
            "email": email,
            "password": password,
            "language": appSettingsManager.language
        ]
        do {
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AuthResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedAppUser = decodedResult.user else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
            return decodedAppUser
        } catch {
            throw error
        }
    }
    
    func deleteAccount(id: Int, sessionKey: String) async throws {
        do {
            guard networkMonitorManager.isConnected else {
                throw NetworkErrors.noConnection
            }
            let path = "/api/auth/delete-user.php"
            var urlComponents: URLComponents {
                var components = URLComponents()
                components.scheme = scheme
                components.host = host
                components.path = path
                return components
            }
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "user_id": String(id),
                "session_key": sessionKey,
            ]
            print(parameters)
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            print(json)
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
        } catch {
            throw error
        }
    }
}
