//
//  AdminNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

enum AdminEndPoints {
    case getCountries
    case getRegions
    case getCities
    case getAdminInfo
}

extension AdminEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        components.queryItems = queryItems()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .getCountries:
            return "/api/admin/get-countries.php"
        case .getRegions:
            return "/api/admin/get-regions-for-country.php"
        case .getCities:
            return "/api/admin/get-cities-for-region.php"
        case .getAdminInfo:
            return "/api/admin/get-admin-info.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
}

protocol AdminNetworkManagerProtocol {
    func getCountries(for user: AppUser) async throws -> [AdminCountry]
    func getRegions(countryID: Int, user: AppUser) async throws  -> [AdminRegion]
    func getCities(regionID: Int, user: AppUser) async throws  -> [AdminCity]
    func getAdminInfo(for user: AppUser) async throws -> AdminInfo
}

final class AdminNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AdminNetworkManager: AdminNetworkManagerProtocol {
    func getCities(regionID: Int, user: AppUser) async throws -> [AdminCity] {
        debugPrint("--- AdminNetworkManager getCities()")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "region_id": String(regionID),
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AdminEndPoints.getCities, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminCitiesResult.self, with: request)
        guard decodedResult.result, let decodedCities = decodedResult.cities else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCities
    }
        
    func getCountries(for user: AppUser) async throws  -> [AdminCountry] {
        debugPrint("--- AdminNetworkManager getCountries()")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AdminEndPoints.getCountries, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminCountriesResult.self, with: request)
        guard decodedResult.result, let decodedCountries = decodedResult.countries else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCountries
    }
    
    func getRegions(countryID: Int, user: AppUser) async throws  -> [AdminRegion] {
        debugPrint("--- AdminNetworkManager getRegions()")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "country_id": String(countryID),
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AdminEndPoints.getRegions, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminRegionsResult.self, with: request)
        guard decodedResult.result, let decodedRegions = decodedResult.regions else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedRegions
    }
    
    func getAdminInfo(for user: AppUser) async throws -> AdminInfo {
        debugPrint("--- AdminNetworkManager getAdminInfo()")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: AdminEndPoints.getAdminInfo, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminInfoResult.self, with: request)
        guard decodedResult.result, let info = decodedResult.info else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return info
    }
}
