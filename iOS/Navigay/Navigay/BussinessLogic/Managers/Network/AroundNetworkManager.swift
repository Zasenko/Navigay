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
    var appSettingsManager: AppSettingsManagerProtocol { get }
    func fetchLocations(location: CLLocation) async throws -> ItemsResult
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult
}

final class AroundNetworkManager {
    
    // MARK: - Properties
    
    var userLocations: [CLLocation] = []
    let appSettingsManager: AppSettingsManagerProtocol //TODO private
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AroundNetworkManager: AroundNetworkManagerProtocol {
    
    private func addToUserLocations(location: CLLocation) {
        userLocations.append(location)
    }
    
    func fetchLocations(location: CLLocation) async throws -> ItemsResult {
        debugPrint("--- fetchLocations around()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/around/get-around.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
                URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd"))
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(AroundResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        addToUserLocations(location: location)
        return decodedItems
    }
    
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult {
        debugPrint("--- fetchLocations around()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/around/around.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
                URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        print(url)
        print(Date().format("yyyy-MM-dd"))

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(AroundResultNew.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        addToUserLocations(location: location)
        return decodedItems
    }
}
