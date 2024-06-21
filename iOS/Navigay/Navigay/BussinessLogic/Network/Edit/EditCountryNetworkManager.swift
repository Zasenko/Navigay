//
//  EditCountryNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.03.24.
//

import SwiftUI

enum EditCountryEndPoint {
    case fetch
    case update
    case updatePhoto
}

extension EditCountryEndPoint: EndPoint {
    
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
            return "/api/admin/get-country.php"
        case .update:
            return "/api/admin/update-country.php"
        case .updatePhoto:
            return "/api/admin/update-country-photo.php"
        }
    }
}


protocol EditCountryNetworkManagerProtocol {
    func fetchCountry(id: Int, for user: AppUser) async throws -> AdminCountry
    func updateCountry(id: Int, name: String, flag: String, about: String, showRegions: Bool, isActive: Bool, isChecked: Bool, user: AppUser) async throws
    func updateCountryPhoto(countryId: Int, uiImage: UIImage, from user: AppUser) async throws -> String
}

final class EditCountryNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension EditCountryNetworkManager: EditCountryNetworkManagerProtocol {
    
    func fetchCountry(id: Int, for user: AppUser) async throws -> AdminCountry {
        debugPrint("--- AdminNetworkManager fetchCountry id \(id)")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "country_id": String(id),
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditCountryEndPoint.fetch, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminCountryResult.self, with: request)
        guard decodedResult.result, let decodedCountry = decodedResult.country else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCountry
    }

    func updateCountry(id: Int, name: String, flag: String, about: String, showRegions: Bool, isActive: Bool, isChecked: Bool, user: AppUser) async throws {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "country_id": String(id),
            "name_en": name,
            "flag_emoji": flag,
            "about": about,
            "show_regions": showRegions ?  "1" : "0",
            "is_active": isActive ? "1" : "0",
            "is_checked": isChecked ? "1" : "0",
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditCountryEndPoint.update, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateCountryPhoto(countryId: Int, uiImage: UIImage, from user: AppUser) async throws -> String {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, countryId: countryId, userID: user.id, sessionKey: sessionKey, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAvatar, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
}

// MARK: - Private Functions

extension EditCountryNetworkManager {
    
    private func createBodyImageUpdating(image: UIImage, countryId: Int, userID: Int, sessionKey: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // country_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"country_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(countryId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userID)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // sessyinKey
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(sessionKey)".data(using: .utf8)!)
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
