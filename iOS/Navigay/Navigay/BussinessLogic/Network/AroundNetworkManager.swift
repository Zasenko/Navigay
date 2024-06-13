//
//  AroundNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.11.23.
//

import SwiftUI
import CoreLocation

enum AroundNetworkEndPoints {
  //  case fetchLocations(location: CLLocation)
    case fetchAround(location: CLLocation)
}

extension AroundNetworkEndPoints: EndPoint {
    
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
    var userLocations: [CLLocation] { get set }  // todo убрать в dataManager
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult
}

final class AroundNetworkManager {
    
    // MARK: - Properties
    
    var userLocations: [CLLocation] = [] // todo убрать в dataManager
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AroundNetworkManager: AroundNetworkManagerProtocol {
    
    private func addToUserLocations(location: CLLocation) {
        userLocations.append(location)
    }
    
    func fetchAround(location: CLLocation) async throws -> AroundItemsResult {
        debugPrint("--- fetchLocations around()")
        
        let request = try await networkManager.request(endpoint: AroundNetworkEndPoints.fetchAround(location: location), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: AroundResultNew.self, with: request)
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        addToUserLocations(location: location) // todo убрать в dataManager
        return decodedItems
    }
}
