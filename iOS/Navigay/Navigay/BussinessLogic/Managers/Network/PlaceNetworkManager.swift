//
//  PlaceNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

protocol PlaceNetworkManagerProtocol {
    var loadedPlaces: [Int] { get }
    func fetchPlace(id: Int) async throws -> DecodedPlace
    func fetchComments(placeID: Int) async throws -> [DecodedComment]
    func addComment(comment: NewComment) async throws
}

final class PlaceNetworkManager {
    
    // MARK: - Properties
    
    var loadedPlaces: [Int] = []
    
    // MARK: - Private Properties
    
    private var loadedComments: [Int:[DecodedComment]] = [:]
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    private let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension PlaceNetworkManager: PlaceNetworkManagerProtocol {
    
    func addComment(comment: NewComment) async throws {
        // TODO: error text!
      //  let errorModel = ErrorModel(massage: "Something went wrong. Your comment has not been upload. Please try again later.", img: nil, color: nil)
        debugPrint("--- PlaceNetworkManager addComment")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/place/add-comment.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }

            guard let url = urlComponents.url else {
                throw NetworkErrors.badUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let jsonData = try JSONEncoder().encode(comment)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func fetchComments(placeID: Int) async throws -> [DecodedComment] {
        if loadedComments.keys.contains(where: { $0 == placeID } ),
           let result = loadedComments[placeID] {
            return result
        }
        // TODO: error text!
        //   let errorModel = ErrorModel(massage: "Something went wrong. The reviews has not been upload. Please try again later.", img: nil, color: nil)
        debugPrint("--- fetchComments for Place id: ", placeID)
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/place/get-comments.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "place_id", value: "\(placeID)"),
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(CommentsResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedComments = decodedResult.comments else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedComments[placeID] = decodedComments
        return decodedComments
    }
    
    func fetchPlace(id: Int) async throws -> DecodedPlace {
        debugPrint("--- fetchPlace id: ", id)
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/place/get-place.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "place_id", value: "\(id)"),
                URLQueryItem(name: "language", value: appSettingsManager.language),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd"))
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(PlaceResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedPlace = decodedResult.place else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedPlaces.append(id)
        return decodedPlace
    }
}
