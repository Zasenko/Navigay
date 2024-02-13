//
//  AuthNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

protocol AuthNetworkManagerProtocol {
    func login(email: String, password: String) async -> DecodedAppUser?
    func registration(email: String, password: String) async -> DecodedAppUser?
}

final class AuthNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(appSettingsManager: AppSettingsManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
    }

}

// MARK: - AuthNetworkManagerProtocol

extension AuthNetworkManager: AuthNetworkManagerProtocol {
    
    func registration(email: String, password: String) async -> DecodedAppUser? {
        debugPrint("--- registration()")
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        let path = "/api/auth/registration.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "email": email,
                "password": password,
                "language": appSettingsManager.language
            ]
            
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
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - AuthNetworkManager registration(email: \(email)) - ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedAppUser
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - AuthNetworkManager registration(email: \(email)) - ", error)
            return nil
        }
    }
    
    func login(email: String, password: String) async -> DecodedAppUser? {
        debugPrint("--- login()")
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        
        let path = "/api/auth/login.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "email": email,
                "password": password,
                "language": appSettingsManager.language
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
            guard let decodedResult = try? JSONDecoder().decode(AuthResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedAppUser = decodedResult.user else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - AuthNetworkManager login(email: \(email)) - ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedAppUser
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - AuthNetworkManager login(email: \(email)) - ", error)
            return nil
        }
    }
}
