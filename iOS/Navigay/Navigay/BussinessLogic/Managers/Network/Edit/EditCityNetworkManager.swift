//
//  EditCityNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.03.24.
//

import SwiftUI

protocol EditCityNetworkManagerProtocol {
    func fetchCity(id: Int, user: AppUser) async throws -> AdminCity
    func updateCity(id: Int, name: String, about: String?, longitude: Double?, latitude: Double?, isCapital: Bool, isParadise: Bool, redirectCity: Int?, isActive: Bool, isChecked: Bool, user: AppUser) async throws
    func updateCityPhoto(cityId: Int, uiImage: UIImage, uiImageSmall: UIImage, user: AppUser) async throws -> PosterUrls
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteCityLibraryPhoto(cityId: Int, photoId: String, from user: AppUser) async throws
}

final class EditCityNetworkManager {
    
    // MARK: - Properties
    
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
        
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
    }
}

// MARK: - CountryNetworkManagerProtocol

extension EditCityNetworkManager: EditCityNetworkManagerProtocol {
    func fetchCity(id: Int, user: AppUser) async throws -> AdminCity {
        debugPrint("--- EditCityNetworkManager fetchCity id \(id)")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/get-city.php"
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
            "city_id": String(id),
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
        guard let decodedResult = try? JSONDecoder().decode(AdminCityResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedCity = decodedResult.city else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedCity
    }
    
    func updateCity(id: Int, name: String, about: String?, longitude: Double?, latitude: Double?, isCapital: Bool, isParadise: Bool, redirectCity: Int?, isActive: Bool, isChecked: Bool, user: AppUser) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/update-city.php"
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
    
    func updateCityPhoto(cityId: Int, uiImage: UIImage, uiImageSmall: UIImage, user: AppUser) async throws -> PosterUrls {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/update-city-photo.php"
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
        request.httpBody = try await createBodyImageUpdating(image: uiImage, smallImage: uiImageSmall, cityId: cityId, userID: user.id, sessionKey: sessionKey, boundary: boundary)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(PosterResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let poster = decodedResult.poster else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return poster
    }
    
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/update-city-library-photo.php"
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
        request.httpBody = try await createBodyLibraryImageUpdating(image: uiImage, cityId: cityId, photoId: photoId, boundary: boundary)
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
    
    func deleteCityLibraryPhoto(cityId: Int, photoId: String, from user: AppUser) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/admin/delete-city-library-photo.php"
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
        let parameters: [String: Any] = [
            "id": cityId,
            "photo_id": photoId
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestData = try JSONSerialization.data(withJSONObject: parameters)
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
    
    private func createBodyLibraryImageUpdating(image: UIImage, cityId: Int, photoId: String, boundary: String) async throws -> Data {
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
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
