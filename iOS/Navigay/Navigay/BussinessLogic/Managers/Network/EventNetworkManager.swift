//
//  EventNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 28.09.23.
//

import Foundation

protocol EventNetworkManagerProtocol {
    func fetchEvent(id: Int) async throws -> EventResult
}

final class EventNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Inits
    
    init(appSettingsManager: AppSettingsManagerProtocol) {
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension EventNetworkManager: EventNetworkManagerProtocol {
    func fetchEvent(id: Int) async throws -> EventResult {
        debugPrint("--- fetchEvent()")
        let path = "/api/events/get-event-by-id.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
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
            guard let decodedResult = try? JSONDecoder().decode(EventResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func fetchCity(id: Int) async throws -> CityResult {
        debugPrint("--- fetchCity()")
        let path = "/api/catalog/get-city-by-id.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
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
            guard let decodedResult = try? JSONDecoder().decode(CityResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
}
