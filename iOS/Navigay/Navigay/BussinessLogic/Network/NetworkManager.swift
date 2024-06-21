//
//  NetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.06.24.
//

import Foundation

protocol EndPoint {
    func urlComponents() -> URLComponents
}

enum APIMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkManagerProtocol {
    func request(endpoint: EndPoint,
                 method: APIMethod,
                 headers: [String: String]?,
                 body: Data?) async throws -> URLRequest
    
    func fetch<T: Codable>(type: T.Type,
                           with request: URLRequest) async throws -> T
    func emptyFetch(with request: URLRequest) async throws
    func getTocken(email: String) throws -> String
}

final class NetworkManager {
    
    // MARK: - Properties
    
    let session: URLSession
    
    // MARK: - Private Properties
    
    private let keychainManager: KeychainManagerProtocol
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    private let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Init
    
    init(session: URLSession, networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol, keychainManager: KeychainManagerProtocol) {
        self.session = session
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
        self.keychainManager = keychainManager
    }
    
    func getTocken(email: String) throws -> String {
        try keychainManager.getGenericPasswordFor(account: email, service: "User tocken")
    }
}

extension NetworkManager: NetworkManagerProtocol {
    
    func request(endpoint: EndPoint, method: APIMethod, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        try await generateRequest(endpoint: endpoint, method: method, headers: headers, body: body)
    }
    
    func fetch<T: Codable>(type: T.Type, with request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.bedResponse
        }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func emptyFetch(with request: URLRequest) async throws {
        let (_, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.bedResponse
        }
    }
}

extension NetworkManager {
    
    private func generateRequest(endpoint: EndPoint, method: APIMethod, headers: [String: String]?, body: Data?) async throws -> URLRequest {
        guard let url = endpoint.urlComponents().url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if method == .get {
            return request
        } else {
            headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
            request.httpBody = body
            return request
        }
    }
}
//
//import UIKit
//
//protocol UserNetworkProtocol: NetworkService {
//    
//    var endpoint: EndPoint { get }
//    func updateName(user: AppUser, name: String) async throws
//    func updateBio(user: AppUser, bio: String?) async throws
//    func updatePhoto(user: AppUser, uiImage: UIImage) async throws -> String
//    func deletePhoto(user: AppUser) async throws
//}
//
//// And at extension we can perform some
//extension UserNetworkProtocol {
//    
//    var endpoint: EndPoint {
//        return PlaceEndPoint
//    }
//    
//    func updateName(user: AppUser, name: String) async throws {
//        /// Creating our request with all necessary parameters.
//        let request = (endpoint: PlaceEndPoint.updateLibraryPhoto,
//                       method: APIMethod.get,
//                       headers: [String: String],
//                       body: Data?)
//        
//        /// Fetching user.
//        return try await fetch(type: User.self, with: request)
//    }
//}
//
//enum PlaceEndPoint: EndPoint {
//    
//    case fetchPlace(id: Int, userDate: String)
//    case updateLibraryPhoto
//    
//    func path() -> String {
//        switch self {
//        case .fetchPlace:
//            return "/api/place/get-place.php"
//        case .updateLibraryPhoto:
//            return "/api/place/update-library-photo.php"
//        }
//    }
//    
//    var queryItems: [URLQueryItem]? {
//        switch self {
//        case .fetchPlace(let id, let userDate):
//            return [
//                URLQueryItem(name: "place_id", value: "\(id)"),
//                URLQueryItem(name: "user_date", value: userDate)
//            ]
//        default:
//            return nil
//        }
//    }
//    
//    func urlComponents() -> URLComponents {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "www.navigay.me"
//        components.path = path()
//        components.queryItems = queryItems
//        return components
//    }
//}
