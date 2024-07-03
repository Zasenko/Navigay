//
//  EditPlaceNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.03.24.
//

import SwiftUI

enum EditPlaceEndPoints {
    case fetchPlace
    case addNewPlace
    case updateAbout
    case updateTitleAndType
    case updateAdditionalInformation
    case updateTimetable
    case updateActivity
    case updateAvatar //TODO
    case deleteAvatar //TODO
    case updateMainPhoto
    case deleteMainPhoto
    case updateLibraryPhoto
    case deleteLibraryPhoto
}

extension EditPlaceEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .fetchPlace:
            return "/api/admin/get-place.php"
        case .addNewPlace:
            return "/api/place/add-new-place.php"
        case .updateAbout:
            return "/api/place/update-about.php"
        case .updateTitleAndType:
            return "/api/place/update-title-and-type.php"
        case .updateAdditionalInformation:
            return "/api/place/update-additional-information.php"
        case .updateTimetable:
            return "/api/place/update-timetable.php"
        case .updateActivity:
            return "/api/place/update-activity.php"
        case .updateAvatar:
            return "/api/place/update-avatar.php"
        case .deleteAvatar:
            return ""
        case .updateMainPhoto:
            return "/api/place/update-main-photo.php"
        case .deleteMainPhoto:
            return ""
        case .updateLibraryPhoto:
            return "/api/place/update-library-photo.php"
        case .deleteLibraryPhoto:
            return "/api/place/delete-library-photo.php"
        }
    }
}

protocol EditPlaceNetworkManagerProtocol {
    var networkManager: NetworkManagerProtocol {get}
    func fetchPlace(id: Int, for user: AppUser) async throws -> AdminPlace
    func addNewPlace(place: NewPlace) async throws -> Int
    func updateAbout(id: Int, about: String?, for user: AppUser) async throws
    func updateTitleAndType(id: Int, name: String, type: PlaceType, for user: AppUser) async throws
    func updateAdditionalInformation(placeId: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?, tags: [Tag]?, for user: AppUser) async throws
    func updateTimetable(placeId: Int, timetable: [PlaceWorkDay]?, for user: AppUser) async throws
    func updateActivity(placeId: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws
    func updateAvatar(placeId: Int, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteAvatar(placeId: Int, from user: AppUser) async throws
    func updateMainPhoto(placeId: Int, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteMainPhoto(placeId: Int, from user: AppUser) async throws
    func updateLibraryPhoto(placeId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteLibraryPhoto(placeId: Int, photoId: String, from user: AppUser) async throws
}

final class EditPlaceNetworkManager {
        
    // MARK: - Private Properties
    
    let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension EditPlaceNetworkManager: EditPlaceNetworkManagerProtocol {
    
    func updateActivity(placeId: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "place_id": String(placeId),
            "is_active": isActive ? "1" : "0",
            "is_checked": isChecked ? "1" : "0",
            "admin_notes": adminNotes,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateActivity, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateTimetable(placeId: Int, timetable: [PlaceWorkDay]?, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        var parameters = [
            "place_id": String(placeId),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        if let timetable {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let timetableData = try encoder.encode(timetable)
            guard let timetableJSONString = String(data: timetableData, encoding: .utf8) else {
                throw NetworkErrors.encoderError
            }
            parameters["timetable"] = timetableJSONString
        }
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateTimetable, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateAdditionalInformation(placeId: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?, tags: [Tag]?, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        var parameters = [
            "place_id": String(placeId),
            "user_id": String(user.id),
            "session_key": tocken,
            "email": email,
            "phone": phone,
            "www": www,
            "facebook": facebook,
            "instagram": instagram,
            "other_info": otherInfo,
        ]
        if let tags = tags {
            let tagsArray = tags.map { $0.rawValue }
            let tagsJSON = try JSONSerialization.data(withJSONObject: tagsArray)
            guard let tagsString = String(data: tagsJSON, encoding: .utf8) else {
                throw NetworkErrors.encoderError
            }
            parameters["tags"] = tagsString
        }
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAdditionalInformation, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateAbout(id: Int, about: String?, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "place_id": String(id),
            "about": about,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAbout, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateTitleAndType(id: Int, name: String, type: PlaceType, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "place_id": String(id),
            "name": name,
            "type": String(type.rawValue),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateTitleAndType, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func deleteAvatar(placeId: Int, from user: AppUser) async throws {
    }
    
    func deleteMainPhoto(placeId: Int, from user: AppUser) async throws {
    }
    
    func fetchPlace(id: Int, for user: AppUser) async throws -> AdminPlace {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "place_id": String(id),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.fetchPlace, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminPlaceResult.self, with: request)
        guard decodedResult.result, let decodedPlace = decodedResult.place else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedPlace
    }
    
    func addNewPlace(place: NewPlace) async throws -> Int {
        let body = try JSONEncoder().encode(place)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.addNewPlace, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: NewPlaceResult.self, with: request)
        guard decodedResult.result, let placeId = decodedResult.placeId else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return placeId
    }
    
    func updateMainPhoto(placeId: Int, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, placeId: placeId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateMainPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
    
    func updateAvatar(placeId: Int, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, placeId: placeId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAvatar, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }

    func updateLibraryPhoto(placeId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyLibraryImageUpdating(image: uiImage, placeId: placeId, photoId: photoId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateLibraryPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
    
    func deleteLibraryPhoto(placeId: Int, photoId: String, from user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters: [String: Any] = [
            "place_id": placeId,
            "photo_id": photoId,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.deleteLibraryPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}

// MARK: - Private Functions

extension EditPlaceNetworkManager {
    private func createBodyImageUpdating(image: UIImage, placeId: Int, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        //place_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"place_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(placeId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
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
    
    private func createBodyLibraryImageUpdating(image: UIImage, placeId: Int, photoId: String, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // place_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"place_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(placeId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userID)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // sessyinKey
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(tocken)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        //photo_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(photoId)\r\n".data(using: .utf8)!)
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
