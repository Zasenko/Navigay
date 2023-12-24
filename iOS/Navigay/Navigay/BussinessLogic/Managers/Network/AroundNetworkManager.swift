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
    func fetchLocations(location: CLLocation) async -> ItemsResult?
}

final class AroundNetworkManager {
    
    // MARK: - Properties
    
    var userLocations: [CLLocation] = []
    let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    private let errorManager: ErrorManagerProtocol
    
    init(appSettingsManager: AppSettingsManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AroundNetworkManager: AroundNetworkManagerProtocol {
    
    func addToUserLocations(location: CLLocation) {
        userLocations.append(location)
    }
    
    func fetchLocations(location: CLLocation) async -> ItemsResult? {
        let errorModel = ErrorModel(massage: "Something went wrong. Failed to upload data. Please try again later.", img: nil, color: nil)
        debugPrint("--- fetchLocations around()")
        
        let path = "/api/around/get-locations-around.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
                URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
            ]
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
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
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - fetchLocations: location \(location) - ", decodedResult.error?.message ?? "")
                return nil
            }
            addToUserLocations(location: location)
            return decodedItems
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - fetchLocations: location \(location) - ", error)
            return nil
        }
    }
    
}
