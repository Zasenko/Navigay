//
//  EditCityNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.03.24.
//

import SwiftUI

enum EditCityEndPoint {
    case fetch
    case update
    case updatePhoto
    case updateLibraryPhoto
    case deleteLibraryPhoto
}

extension EditCityEndPoint: EndPoint {
    
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
            return "/api/admin/get-city.php"
        case .update:
            return "/api/admin/update-city.php"
        case .updatePhoto:
            return "/api/admin/update-city-photo.php"
        case .updateLibraryPhoto:
            return "/api/admin/update-city-library-photo.php"
        case .deleteLibraryPhoto:
            return "/api/admin/delete-city-library-photo.php"
        }
    }
}

protocol EditCityNetworkManagerProtocol {
    func fetchCity(id: Int, user: AppUser) async throws -> AdminCity
    func updateCity(id: Int, name: String, about: String?, longitude: Double?, latitude: Double?, isCapital: Bool, isParadise: Bool, redirectCity: Int?, isActive: Bool, isChecked: Bool, user: AppUser) async throws
    func updateCityPhoto(cityId: Int, uiImage: UIImage, uiImageSmall: UIImage, user: AppUser) async throws -> PosterUrls
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteCityLibraryPhoto(cityId: Int, photoId: String, from user: AppUser) async throws
}

final class EditCityNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - CountryNetworkManagerProtocol

extension EditCityNetworkManager: EditCityNetworkManagerProtocol {
    
    func fetchCity(id: Int, user: AppUser) async throws -> AdminCity {
        debugPrint("--- EditCityNetworkManager fetchCity id \(id)")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters = [
            "city_id": String(id),
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditCityEndPoint.fetch, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminCityResult.self, with: request)
        guard decodedResult.result, let decodedCity = decodedResult.city else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCity
    }
    
    func updateCity(id: Int, name: String, about: String?, longitude: Double?, latitude: Double?, isCapital: Bool, isParadise: Bool, redirectCity: Int?, isActive: Bool, isChecked: Bool, user: AppUser) async throws {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        var parameters = [
            "city_id": String(id),
            "name_en": name,
            "about": about,
            "is_gay_paradise": isParadise ? "1" : "0",
            "is_capital": isCapital ? "1" : "0",
            "is_active": isActive ? "1" : "0",
            "is_checked": isChecked ? "1" : "0",
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        if let longitude, let latitude {
               parameters["longitude"] = String(longitude)
               parameters["latitude"] = String(latitude)
           }
        if let redirectCity {
            parameters["redirect_city_id"] = String(redirectCity)
        }
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditCityEndPoint.update, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateCityPhoto(cityId: Int, uiImage: UIImage, uiImageSmall: UIImage, user: AppUser) async throws -> PosterUrls {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, smallImage: uiImageSmall, cityId: cityId, userID: user.id, sessionKey: sessionKey, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditCityEndPoint.updatePhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: PosterResult.self, with: request)
        guard decodedResult.result, let poster = decodedResult.poster else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return poster
    }
    
    // TODO: - sessionKey API!!!!!!!
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyLibraryImageUpdating(image: uiImage, cityId: cityId, photoId: photoId, userID: user.id, sessionKey: sessionKey, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditCityEndPoint.updateLibraryPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
    
    // TODO: - sessionKey в API!!!!!!!
    func deleteCityLibraryPhoto(cityId: Int, photoId: String, from user: AppUser) async throws {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let parameters: [String: Any] = [
            "id": cityId,
            "photo_id": photoId,
            "user_id": String(user.id),
            "session_key": sessionKey,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditCityEndPoint.deleteLibraryPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}

// MARK: - Private Functions

extension EditCityNetworkManager {
    private func createBodyImageUpdating(image: UIImage, smallImage: UIImage, cityId: Int, userID: Int, sessionKey: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let smallImageData = smallImage.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // city_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"city_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(cityId)\r\n".data(using: .utf8)!)
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
        // image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        // small_image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"small_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(smallImageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func createBodyLibraryImageUpdating(image: UIImage, cityId: Int, photoId: String, userID: Int, sessionKey: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(cityId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(photoId)\r\n".data(using: .utf8)!)
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
        
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
