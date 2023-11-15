//
//  AdminNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import SwiftUI

protocol AdminNetworkManagerProtocol {
    func getAdminInfo() async throws -> AdminInfoResult
    func updateCountry(country: AdminCountry) async throws -> ApiResult
    func updateCountryPhoto(countryId: Int, uiImage: UIImage) async throws -> ImageResult
    func updateRegion(region: AdminRegion) async throws -> ApiResult
    func updateRegionPhoto(regionId: Int, uiImage: UIImage) async throws -> ImageResult
    func updateCity(city: AdminCity) async throws -> ApiResult
    func updateCityPhoto(cityId: Int, uiImage: UIImage) async throws -> ImageResult
    func updateCityLibraryPhoto(cityId: Int, photoId: UUID, uiImage: UIImage) async throws -> ImageResult
    func deleteCityLibraryPhoto(cityId: Int, photoId: UUID) async throws -> ApiResult
}

final class AdminNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
}

// MARK: - AuthNetworkManagerProtocol

extension AdminNetworkManager: AdminNetworkManagerProtocol {
    
    func getAdminInfo() async throws -> AdminInfoResult {
        debugPrint("--- getAdminInfo()")
        let path = "/api/admin/get-admin-info.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminInfoResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateCountry(country: AdminCountry) async throws -> ApiResult {
        let path = "/api/admin/update-country.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(country)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateCountryPhoto(countryId: Int, uiImage: UIImage) async throws -> ImageResult {
        let path = "/api/admin/update-country-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try await createBodyImageUpdating(image: uiImage, id: countryId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateRegion(region: AdminRegion) async throws -> ApiResult {
        let path = "/api/admin/update-region.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(region)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateRegionPhoto(regionId: Int, uiImage: UIImage) async throws -> ImageResult {
        let path = "/api/admin/update-region-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try await createBodyImageUpdating(image: uiImage, id: regionId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateCity(city: AdminCity) async throws -> ApiResult {
        let path = "/api/admin/update-city.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(city)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateCityPhoto(cityId: Int, uiImage: UIImage) async throws -> ImageResult {
        let path = "/api/admin/update-city-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try await createBodyImageUpdating(image: uiImage, id: cityId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updateCityLibraryPhoto(cityId: Int, photoId: UUID, uiImage: UIImage) async throws -> ImageResult {
        let path = "/api/admin/update-city-library-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try await createBodyLibraryImageUpdating(image: uiImage, cityId: cityId, photoId: photoId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func deleteCityLibraryPhoto(cityId: Int, photoId: UUID) async throws -> ApiResult {
        let path = "/api/admin/delete-city-library-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        let parameters: [String: Any] = [
            "id": cityId,
            "photo_id": photoId.uuidString
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
}

// MARK: - Private Functions

extension AdminNetworkManager {
    
    private func createBodyImageUpdating(image: UIImage, id: Int, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(id)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func createBodyLibraryImageUpdating(image: UIImage, cityId: Int, photoId: UUID, boundary: String) async throws -> Data {
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
