//
//  PlaceNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

protocol PlaceNetworkManagerProtocol {
    func addNewPlace(place: NewPlace) async throws -> NewPlaceResult
    func updateAvatar(placeId: Int, uiImage: UIImage) async throws
    func updateMainPhoto(placeId: Int, uiImage: UIImage) async throws
    func updateLibraryPhoto(placeId: Int, photoId: UUID, uiImage: UIImage) async throws
    func deleteLibraryPhoto(placeId: Int, photoId: UUID) async throws
   // func addAdditionalInfoToPlace(place: PlaceAdditionalInfo) async throws -> NewPlaceResult
    //func addNewPlace(place: NewPlace, uiImageSmall: UIImage?, uiImageBig: UIImage?) async throws -> DecodedPlace
}

final class PlaceNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(errorManager: ErrorManagerProtocol) {
        self.errorManager = errorManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension PlaceNetworkManager: PlaceNetworkManagerProtocol {
    
    func addNewPlace(place: NewPlace) async throws -> NewPlaceResult {
        let path = "/api/place/add-new-place.php"
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
            guard let decodedResult = try? JSONDecoder().decode(NewPlaceResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            debugPrint("ERROR - addNewPlace: ",error)
            throw error
        }
    }
    
    func updateMainPhoto(placeId: Int, uiImage: UIImage) async throws {
        let path = "/api/place/update-main-photo.php"
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
            request.httpBody = try await createBodyImageUpdating(image: uiImage, placeId: placeId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                throw NetworkErrors.apiError
            }
        } catch {
            debugPrint("ERROR - updateMainPhoto: ",error)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            throw error
        }
    }
    
    func updateAvatar(placeId: Int, uiImage: UIImage) async throws {
        let path = "/api/place/update-avatar.php"
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
            request.httpBody = try await createBodyImageUpdating(image: uiImage, placeId: placeId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                throw NetworkErrors.apiError
            }
        } catch {
            debugPrint("ERROR - updateAvatar: ",error)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            throw error
        }
    }

    func updateLibraryPhoto(placeId: Int, photoId: UUID, uiImage: UIImage) async throws {
        let path = "/api/place/update-library-photo.php"
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
            request.httpBody = try await createBodyLibraryImageUpdating(image: uiImage, placeId: placeId, photoId: photoId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                throw NetworkErrors.apiError
            }
        } catch {
            debugPrint("ERROR - updateLibraryPhoto: ",error)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            throw error
        }
    }
    
    func deleteLibraryPhoto(placeId: Int, photoId: UUID) async throws {
        let path = "/api/place/delete-library-photo.php"
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
            "place_id": placeId,
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
            guard let decodedResult = try? JSONDecoder().decode(DeleteResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                debugPrint(decodedResult.error?.message ?? "---ERROR----")
                let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't delete. Please try again later.", img: Image(systemName: "trash.slash.fill"), color: .red)
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                throw NetworkErrors.apiError
            }
        } catch {
            debugPrint("ERROR - deleteLibraryPhoto: ",error)
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            throw error
        }
    }
    
}

// MARK: - Private Functions

extension PlaceNetworkManager {
    
    private func createBodyImageUpdating(image: UIImage, placeId: Int, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        body.append("Content-Disposition: form-data; name=\"place_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(placeId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func createBodyLibraryImageUpdating(image: UIImage, placeId: Int, photoId: UUID, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"place_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(placeId)\r\n".data(using: .utf8)!)
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
    
//    private func createBodyLibraryImageDelete(placeId: Int, photoId: UUID, boundary: String) async throws -> Data {
//        var body = Data()
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"place_id\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(placeId)\r\n".data(using: .utf8)!)
//        body.append("\r\n".data(using: .utf8)!)
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"photo_id\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(photoId)\r\n".data(using: .utf8)!)
//        body.append("\r\n".data(using: .utf8)!)
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        return body
//    }
    
//    private func encodeData(string: String) throws -> Data {
//        guard let data = string.data(using: .utf8) else {
//            throw NetworkErrors.bodyEncoderError
//        }
//    }
}
