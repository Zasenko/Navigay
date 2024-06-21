//
//  UserNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 06.10.23.
//

import SwiftUI

enum UserEndPoints {
    case deletePhoto
    case updatePhoto
    case updateBio
    case updateName
}

extension UserEndPoints: EndPoint {
    
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
        case .deletePhoto:
            return "/api/user/delete-photo.php"
        case .updatePhoto:
            return "/api/user/update-photo.php"
        case .updateBio:
            return "/api/user/update-bio.php"
        case .updateName:
            return "/api/user/update-name.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
}

protocol UserNetworkManagerProtocol {
    func updateName(for user: AppUser, name: String) async throws
    func updateBio(for user: AppUser, bio: String?) async throws
    func updatePhoto(for user: AppUser, uiImage: UIImage) async throws -> String
    func deletePhoto(for user: AppUser) async throws
}

final class UserNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension UserNetworkManager: UserNetworkManagerProtocol {
    
    func deletePhoto(for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: UserEndPoints.deletePhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateName(for user: AppUser, name: String) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "user_id": String(user.id),
            "user_name": name,
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: UserEndPoints.updateName, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateBio(for user: AppUser, bio: String?) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "user_id": String(user.id),
            "user_bio": bio,
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: UserEndPoints.updateBio, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updatePhoto(for user: AppUser, uiImage: UIImage) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(userID: user.id, tocken: tocken, image: uiImage, boundary: boundary)
        let request = try await networkManager.request(endpoint: UserEndPoints.updatePhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
}

extension UserNetworkManager {
    
    private func createBodyImageUpdating(userID: Int, tocken: String, image: UIImage, boundary: String) async throws -> Data {
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
        body.append("\(tocken)".data(using: .utf8)!)
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
