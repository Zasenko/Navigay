//
//  AroundNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.11.23.
//

import SwiftUI
import CoreLocation

protocol AroundNetworkManagerProtocol {
    var userLocations: [CLLocation] { get set }
    func addToUserLocations(location: CLLocation)
    
    var appSettingsManager: AppSettingsManagerProtocol { get }
    func fetchLocations(latitude: Double, longitude: Double) async throws -> AroundResult
}

final class AroundNetworkManager {
    
    // MARK: - Properties
    
    var userLocations: [CLLocation] = []
    let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    init(appSettingsManager: AppSettingsManagerProtocol) {
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AroundNetworkManager: AroundNetworkManagerProtocol {
    
    func addToUserLocations(location: CLLocation) {
        userLocations.append(location)
    }
    
    func fetchLocations(latitude: Double, longitude: Double) async throws -> AroundResult {
        debugPrint("--- fetchLocations around()")
        let path = "/api/around/get-locations-around.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(latitude)"),
                URLQueryItem(name: "longitude", value: "\(longitude)"),
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
            guard let decodedResult = try? JSONDecoder().decode(AroundResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
}
