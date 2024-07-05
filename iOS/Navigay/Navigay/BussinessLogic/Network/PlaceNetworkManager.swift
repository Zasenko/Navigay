//
//  PlaceNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import Foundation

enum PlaceEndPoints {
    case fetchPlace(id: Int)
}

extension PlaceEndPoints: EndPoint {
    
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
        case .fetchPlace(_):
            return "/api/place/get-place.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchPlace(let id):
            return [
                URLQueryItem(name: "place_id", value: "\(id)"),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))
            ]
        }
    }
}

protocol PlaceNetworkManagerProtocol {
    func fetchPlace(id: Int) async throws -> DecodedPlace
}

final class PlaceNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension PlaceNetworkManager: PlaceNetworkManagerProtocol {

    func fetchPlace(id: Int) async throws -> DecodedPlace {
        debugPrint("--- fetchPlace id: ", id)
        let request = try await networkManager.request(endpoint: PlaceEndPoints.fetchPlace(id: id), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: PlaceResult.self, with: request)
        guard decodedResult.result, let decodedPlace = decodedResult.place else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedPlace
    }
}
