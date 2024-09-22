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
    
    func getTocken(email: String) throws -> String {
        try keychainManager.getGenericPasswordFor(account: email, service: KeychainService.tocken.rawValue)
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
