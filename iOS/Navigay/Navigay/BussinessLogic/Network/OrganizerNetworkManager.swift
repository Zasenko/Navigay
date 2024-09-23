//
//  OrganizerNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import Foundation

enum OrganizerEndPoints {
    case fetchOrganizer(id: Int)
}

extension OrganizerEndPoints: EndPoint {
    
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
        case .fetchOrganizer(_):
            return "/api/organizer/get-organizer.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchOrganizer(let id):
            return [
                URLQueryItem(name: "organizer_id", value: "\(id)"),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))
            ]
        }
    }
}

protocol OrganizerNetworkManagerProtocol {
    func fetchOrganizer(id: Int) async throws -> DecodedOrganizer
}

final class OrganizerNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension OrganizerNetworkManager: OrganizerNetworkManagerProtocol {

    func fetchOrganizer(id: Int) async throws -> DecodedOrganizer {
        debugPrint("--- fetchOrganizer id: ", id)
        let request = try await networkManager.request(endpoint: OrganizerEndPoints.fetchOrganizer(id: id), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: OrganizerResult.self, with: request)
        guard decodedResult.result, let decodedOrganizer = decodedResult.organizer else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedOrganizer
    }
}
