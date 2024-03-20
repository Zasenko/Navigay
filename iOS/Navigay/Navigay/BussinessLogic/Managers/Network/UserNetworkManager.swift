//
//  UserNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 06.10.23.
//

import Foundation
import SwiftUI

protocol UserNetworkManagerProtocol {
    func updateName(for user: AppUser, name: String) async throws
    func updateBio(for user: AppUser, bio: String?) async throws
    func updatePhoto(for user: AppUser, uiImage: UIImage) async throws -> String
    func deletePhoto(for user: AppUser) async throws
}

final class UserNetworkManager {
    
    // MARK: - Private Properties
    
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

extension UserNetworkManager: UserNetworkManagerProtocol {
    func deletePhoto(for user: AppUser) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/user/delete-photo.php"
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
        let parameters = [
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let requestData = try JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
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
    
    func updateName(for user: AppUser, name: String) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/user/update-name.php"
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
        let parameters = [
            "user_id": String(user.id),
            "user_name": name,
            "session_key": sessionKey,
        ]
        let requestData = try JSONSerialization.data(withJSONObject: parameters)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
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
    
    func updateBio(for user: AppUser, bio: String?) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/user/update-bio.php"
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
            let parameters = [
                "user_id": String(user.id),
                "user_bio": bio,
                "session_key": sessionKey,
            ]
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
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
    
    func updatePhoto(for user: AppUser, uiImage: UIImage) async throws -> String {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/user/update-photo.php"
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
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try await createBodyImageUpdating(userID: user.id, key: sessionKey, image: uiImage, boundary: boundary)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
}

extension UserNetworkManager {
    
    private func createBodyImageUpdating(userID: Int, key: String, image: UIImage, boundary: String) async throws -> Data {
        var body = Data()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userID)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(key)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
