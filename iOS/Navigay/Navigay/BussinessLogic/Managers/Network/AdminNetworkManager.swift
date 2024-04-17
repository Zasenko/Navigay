//
//  AdminNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import SwiftUI

protocol AdminNetworkManagerProtocol {
    func getCountries(for user: AppUser) async throws -> [AdminCountry]
    func getRegions(countryID: Int, user: AppUser) async throws  -> [AdminRegion]
    func getAdminInfo(for user: AppUser) async throws -> AdminInfo
}

final class AdminNetworkManager {
    
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

extension AdminNetworkManager: AdminNetworkManagerProtocol {
        
    func getCountries(for user: AppUser) async throws  -> [AdminCountry] {
        debugPrint("--- AdminNetworkManager getCountries()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/get-countries.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        let parameters = [
            "user_id": String(user.id),
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
        guard let decodedResult = try? JSONDecoder().decode(AdminCountriesResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedCountries = decodedResult.countries else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCountries
    }
    
    func getRegions(countryID: Int, user: AppUser) async throws  -> [AdminRegion] {
        debugPrint("--- AdminNetworkManager getRegions()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/get-regions-for-country.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        let parameters = [
            "country_id": String(countryID),
            "user_id": String(user.id),
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
        guard let decodedResult = try? JSONDecoder().decode(AdminRegionsResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedRegions = decodedResult.regions else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedRegions
    }
    
    func getAdminInfo(for user: AppUser) async throws -> AdminInfo {
        debugPrint("--- AdminNetworkManager getAdminInfo()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/get-admin-info.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        let parameters = [
            "user_id": String(user.id),
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
        guard let decodedResult = try? JSONDecoder().decode(AdminInfoResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let info = decodedResult.info else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return info
    }
}
