//
//  AdminNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

protocol AdminNetworkManagerProtocol {
    func getAdminInfo() async throws -> AdminInfoResult
}

final class AdminNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    // MARK: - Inits
}

// MARK: - AuthNetworkManagerProtocol

extension AdminNetworkManager: AdminNetworkManagerProtocol {
    func getAdminInfo() async throws -> AdminInfoResult {
        debugPrint("--- getAdminInfo()")
        let path = "/api/admin/get-admin-info.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
//            components.queryItems = [
//                URLQueryItem(name: "language", value: self.appSettingsManager.language)
//            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminInfoResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
}
