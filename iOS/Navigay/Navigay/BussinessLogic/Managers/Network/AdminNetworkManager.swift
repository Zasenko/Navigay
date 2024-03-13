//
//  AdminNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import SwiftUI

protocol AdminNetworkManagerProtocol {
    
    func fetchEvent(id: Int, for user: AppUser) async throws -> AdminEvent
    
    
    func updateCity(city: AdminCity) async -> Bool
    
    func getCountries() async -> [AdminCountry]?
    
  //  func fetchRegions(country id: Int) async -> AdminCountry?
    
    
    func fetchCountry(id: Int) async -> AdminCountry?
    func fetchCity(id: Int) async -> AdminCity?
    func fetchPlace(id: Int) async -> AdminPlace?
    
    func updatePlaceAbout(id: Int, about: String) async -> Bool
    func updateEventAbout(id: Int, about: String) async -> Bool
    
    //TODO: избавиться от throws (ошибку обрабатывать тут на примере fetchPlace)
    func getAdminInfo() async throws -> AdminInfoResult
    func updateCountry(country: AdminCountry) async throws -> ApiResult
    func updateCountryPhoto(countryId: Int, uiImage: UIImage) async throws -> ImageResult
    func updateRegion(region: AdminRegion) async throws -> ApiResult
    func updateRegionPhoto(regionId: Int, uiImage: UIImage) async throws -> ImageResult
    
    func updateCityPhoto(cityId: Int, uiImage: UIImage) async throws -> ImageResult
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage) async throws -> ImageResult
    func deleteCityLibraryPhoto(cityId: Int, photoId: String) async throws -> ApiResult
}

final class AdminNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let errorManager: ErrorManagerProtocol
    
    init(errorManager: ErrorManagerProtocol) {
        self.errorManager = errorManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension AdminNetworkManager: AdminNetworkManagerProtocol {
    
    func fetchEvent(id: Int, for user: AppUser) async throws -> AdminEvent {
        debugPrint("-AdminNetworkManager- getEvent id \(id)")
        let path = "/api/admin/get-event.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let sessionKey = user.sessionKey else {
                throw NetworkErrors.noSessionKey
            }
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "event_id": String(id),
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
            guard let decodedResult = try? JSONDecoder().decode(AdminEventResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedEvent = decodedResult.event else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
            return decodedEvent
        } catch {
            throw error
        }
    }

    func updateCity(city: AdminCity) async -> Bool {
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager updateCity(city id: \(city.id))")
        let path = "/api/admin/update-city.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONEncoder().encode(city)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager updateCity(city id: \(city.id))", decodedResult.error?.message ?? "")
                return false
            }
            return true
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager updateCity(city id: \(city.id)) : ", error)
            return false
        }
    }
    
    
    func updatePlaceAbout(id: Int, about: String) async -> Bool {
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager updatePlaceAbout place id \(id)")
        let path = "/api/admin/update-place-about.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "place_id": String(id),
                "about": about,
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
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager updatePlaceAbout place id \(id) : ", decodedResult.error?.message ?? "")
                return false
            }
            return true
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager updatePlaceAbout place id \(id) : ", error)
            return false
        }
        
    }
    
    func updateEventAbout(id: Int, about: String) async -> Bool {
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager updateEventAbout event id \(id)")
        let path = "/api/admin/update-event-about.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "event_id": String(id),
                "about": about,
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
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager updateEventAbout event id \(id) : ", decodedResult.error?.message ?? "")
                return false
            }
            return true
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager updateEventAbout event id \(id) : ", error)
            return false
        }
        
    }
    
    func fetchPlace(id: Int) async -> AdminPlace? {
        let errorModel = ErrorModel(massage: "Something went wrong. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager fetchPlace id \(id)")
        let path = "/api/admin/get-place.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
            ]
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminPlaceResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedPlace = decodedResult.place else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager fetchPlace id \(id) : ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedPlace
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager fetchPlace id \(id) : ", error)
            return nil
        }
    }
    
    
    func fetchCity(id: Int) async -> AdminCity? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager fetchCity id \(id)")
        let path = "/api/admin/get-city.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
            ]
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminCityResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedCity = decodedResult.city else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager fetchCity id \(id) : ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedCity
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager fetchCity id \(id) : ", error)
            return nil
        }
    }
    
    func fetchCountry(id: Int) async -> AdminCountry? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been upload. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager fetchCountry id \(id)")
        let path = "/api/admin/get-country.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
            ]
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminCountryResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedCountry = decodedResult.country else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager fetchCountry id \(id) : ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedCountry
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager fetchCountry id \(id) : ", error)
            return nil
        }
    }
    
    func getCountries() async  -> [AdminCountry]? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
        debugPrint("--- AdminNetworkManager getCountries()")
        let path = "/api/admin/get-countries.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(AdminCountriesResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedCountries = decodedResult.countries else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("-API ERROR- AdminNetworkManager getCountries: ", decodedResult.error?.message ?? "")
                return nil
            }
            return decodedCountries
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("-ERROR- AdminNetworkManager getCountries : ", error)
            return nil
        }
    }
    
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
    
    func updateCityLibraryPhoto(cityId: Int, photoId: String, uiImage: UIImage) async throws -> ImageResult {
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
    
    func deleteCityLibraryPhoto(cityId: Int, photoId: String) async throws -> ApiResult {
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
            "photo_id": photoId
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
