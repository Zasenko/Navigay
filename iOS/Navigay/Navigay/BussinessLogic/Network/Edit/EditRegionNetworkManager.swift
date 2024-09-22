//
//  EditRegionNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.03.24.
//

import SwiftUI

enum EditRegionEndPoint {
    case fetch
    case update
    case updatePhoto
}

extension EditRegionEndPoint: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .fetch:
            return "/api/admin/get-region.php"
        case .update:
            return "/api/admin/update-region.php"
        case .updatePhoto:
            return "/api/admin/update-region-photo.php"
        }
    }
}

protocol EditRegionNetworkManagerProtocol {
    func fetchRegion(id: Int, user: AppUser) async throws -> AdminRegion
    func updateRegion(id: Int, name: String, isActive: Bool, isChecked: Bool, user: AppUser) async throws
    func updateRegionPhoto(regionId: Int, uiImage: UIImage, user: AppUser) async throws -> String
}

final class EditRegionNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension EditRegionNetworkManager: EditRegionNetworkManagerProtocol {
    
    func fetchRegion(id: Int, user: AppUser) async throws -> AdminRegion {
        debugPrint("--- EditRegionNetworkManager fetchRegion id \(id)")
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "region_id": String(id),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditRegionEndPoint.fetch, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminRegionResult.self, with: request)
        guard decodedResult.result, let decodedRegion = decodedResult.region else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedRegion
    }
    
    func updateRegion(id: Int, name: String, isActive: Bool, isChecked: Bool, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "region_id": String(id),
            "name_en": name,
            "is_active": isActive ? "1" : "0",
            "is_checked": isChecked ? "1" : "0",
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditRegionEndPoint.update, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateRegionPhoto(regionId: Int, uiImage: UIImage, user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, regionId: regionId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditRegionEndPoint.updatePhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
}

// MARK: - Private Functions

extension EditRegionNetworkManager {
    
    private func createBodyImageUpdating(image: UIImage, regionId: Int, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        // country_id
        body.append("Content-Disposition: form-data; name=\"region_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(regionId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        // user_id
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userID)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // sessyinKey
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(tocken)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        //image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
