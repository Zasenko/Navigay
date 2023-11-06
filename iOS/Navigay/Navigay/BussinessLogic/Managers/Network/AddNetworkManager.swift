//
//  AddNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

protocol AddNetworkManagerProtocol {
    func addNewPlace(place: PlaceRequiredInfo) async throws -> NewPlaceResult
    func addAdditionalInfoToPlace(place: PlaceAdditionalInfo) async throws -> NewPlaceResult
    //func addNewPlace(place: NewPlace, uiImageSmall: UIImage?, uiImageBig: UIImage?) async throws -> DecodedPlace
}

final class AddNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
}

// MARK: - AuthNetworkManagerProtocol

extension AddNetworkManager: AddNetworkManagerProtocol {
    
    func addNewPlace(place: PlaceRequiredInfo) async throws -> NewPlaceResult {
        debugPrint("--- addNewPlace()")
        let path = "/api/places/add-new-place.php"
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
            let jsonData = try JSONEncoder().encode(place)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            print(json)
            guard let decodedResult = try? JSONDecoder().decode(NewPlaceResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func addAdditionalInfoToPlace(place: PlaceAdditionalInfo) async throws -> NewPlaceResult {
        debugPrint("--- addAdditionalInfoToPlace()")
        let path = "/api/places/add-additional-info-to-place.php"
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
            let jsonData = try JSONEncoder().encode(place)
            print(jsonData)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8) ?? "default value")
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            print(json)
            guard let decodedResult = try? JSONDecoder().decode(NewPlaceResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
//    func addNewPlace(place: NewPlace, uiImageSmall: UIImage?, uiImageBig: UIImage?) async throws -> DecodedPlace {
//        let path = "/api/add-new-place.php"
//        var urlComponents: URLComponents {
//            var components = URLComponents()
//            components.scheme = scheme
//            components.host = host
//            components.path = path
//            return components
//        }
//        guard let url = urlComponents.url else {
//            throw NetworkErrors.bedUrl
//        }
//        let encoder = JSONEncoder()
//        guard let jsonData = try? encoder.encode(place) else {
//            throw NetworkErrors.encoderError
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        let contentType = "multipart/form-data; boundary=\(boundary)"
//        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
//        let body = createAddNewPlaceBody(uiImageSmall: uiImageSmall, uiImageBig: uiImageBig, jsonData: jsonData, boundary: boundary)
//        request.httpBody = body
//        
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                throw NetworkErrors.invalidData
//            }
//            guard let decodedResult = try? JSONDecoder().decode(NewPlaceResult.self, from: data) else {
//                throw NetworkErrors.decoderError
//            }
//            guard let place = decodedResult.place else {
//                throw CatalogNetworkManagerErrors.noCity
//            }
//            return place
//        } catch {
//            throw error
//        }
//    }
}

// MARK: - Private Functions

extension AddNetworkManager {
    
//    private func createAddNewPlaceBody(uiImageSmall: UIImage?, uiImageBig: UIImage?, jsonData: Data, boundary: String) -> Data {
//        var body = Data()
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"place\"\r\n\r\n".data(using: .utf8)!)
//        body.append(jsonData)
//        body.append("\r\n".data(using: .utf8)!)
//        if let smallImage = uiImageSmall, let smallImageData = smallImage.jpegData(compressionQuality: 0.8) {
//            // Add images to the request body
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"smallImage\"; filename=\"smallImage.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(smallImageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//        if let bigImage = uiImageBig, let bigImageData = bigImage.jpegData(compressionQuality: 0.8) {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"bigImage\"; filename=\"bigImage.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            body.append(bigImageData)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        return body
//    }
}
