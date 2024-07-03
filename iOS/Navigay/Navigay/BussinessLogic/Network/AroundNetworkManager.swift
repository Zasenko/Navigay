//
//  AroundNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.11.23.
//

import Foundation
import CoreLocation

enum AroundEndPoint {
    case fetchAround(location: CLLocation)
}

extension AroundEndPoint: EndPoint {
    
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
        case .fetchAround:
            return "/api/around/around.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchAround(let location):
            return [URLQueryItem(name: "latitude", value: "\(location.coordinate.latitude)"),
                    URLQueryItem(name: "longitude", value: "\(location.coordinate.longitude)"),
                    URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))]
        }
    }
}

protocol AroundNetworkManagerProtocol {
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult
}

final class AroundNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AroundNetworkManager: AroundNetworkManagerProtocol {
    
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult {
        debugPrint("--- fetchLocations around()")
        let request = try await networkManager.request(endpoint: AroundEndPoint.fetchAround(location: location), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: AroundResultNew.self, with: request)
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedItems
    }
}
