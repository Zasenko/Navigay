//
//  EditOrganizerNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.09.24.
//

import SwiftUI

enum EditOrganizerEndPoints {
    case fetch
    case add
    case updateAbout
    case updateTitle
    case updateAdditionalInformation
    case updateActivity
    case updateAvatar //TODO
    case deleteAvatar //TODO
    case updateMainPhoto
    case deleteMainPhoto
    case updateLibraryPhoto
    case deleteLibraryPhoto
}

extension EditOrganizerEndPoints: EndPoint {
    
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
            return "/api/admin/get-organizer.php"
        case .add:
            return "/api/organizer/add-new-organizer.php"
        case .updateAbout:
            return "/api/organizer/update-about.php"
        case .updateTitle:
            return "/api/organizer/update-title.php"
        case .updateAdditionalInformation:
            return "/api/organizer/update-additional-information.php"
        case .updateActivity:
            return "/api/organizer/update-activity.php"
        case .updateAvatar:
            return "/api/organizer/update-avatar.php"
        case .deleteAvatar:
            return ""
        case .updateMainPhoto:
            return "/api/organizer/update-main-photo.php"
        case .deleteMainPhoto:
            return ""
        case .updateLibraryPhoto:
            return "/api/organizer/update-library-photo.php"
        case .deleteLibraryPhoto:
            return "/api/organizer/delete-library-photo.php"
        }
    }
}

protocol EditOrganizerNetworkManagerProtocol {
    var networkManager: NetworkManagerProtocol {get}
    func fetch(organizerId: Int, for user: AppUser) async throws -> AdminPlace
    func add(organizer: NewOrganizer) async throws -> Int
    func updateAbout(organizerId: Int, about: String?, for user: AppUser) async throws
    func updateTitle(organizerId: Int, name: String, for user: AppUser) async throws
    func updateAdditionalInformation(organizerId: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?, for user: AppUser) async throws
    func updateActivity(organizerId: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws
    func updateAvatar(organizerId: Int, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteAvatar(organizerId: Int, from user: AppUser) async throws
    func updateMainPhoto(organizerId: Int, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteMainPhoto(organizerId: Int, from user: AppUser) async throws
    func updateLibraryPhoto(organizerId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String
    func deleteLibraryPhoto(organizerId: Int, photoId: String, from user: AppUser) async throws
}

final class EditOrganizerNetworkManager {
        
    // MARK: - Private Properties
    
    let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension EditOrganizerNetworkManager: EditOrganizerNetworkManagerProtocol {

    func updateActivity(organizerId: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "organizer_id": String(organizerId),
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
        
    func updateAdditionalInformation(organizerId: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, otherInfo: String?, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        var parameters = [
            "organizer_id": String(organizerId),
            "user_id": String(user.id),
            "session_key": tocken,
            "email": email,
            "phone": phone,
            "www": www,
            "facebook": facebook,
            "instagram": instagram,
            "other_info": otherInfo,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAdditionalInformation, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateAbout(organizerId: Int, about: String?, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "organizer_id": String(organizerId),
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
    
    func updateTitle(organizerId: Int, name: String, for user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "organizer_id": String(organizerId),
            "name": name,
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
    
    func deleteAvatar(organizerId: Int, from user: AppUser) async throws {
    }
    
    func deleteMainPhoto(organizerId: Int, from user: AppUser) async throws {
    }
    
    func fetch(organizerId: Int, for user: AppUser) async throws -> AdminPlace {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "organizer_id": String(organizerId),
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
    
    func add(organizer: NewOrganizer) async throws -> Int {
        let body = try JSONEncoder().encode(organizer)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.addNewPlace, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: NewPlaceResult.self, with: request)
        guard decodedResult.result, let placeId = decodedResult.placeId else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return placeId
    }
    
    func updateMainPhoto(organizerId: Int, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, organizerId: organizerId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateMainPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
    
    func updateAvatar(organizerId: Int, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyImageUpdating(image: uiImage, organizerId: organizerId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateAvatar, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }

    func updateLibraryPhoto(organizerId: Int, photoId: String, uiImage: UIImage, from user: AppUser) async throws -> String {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyLibraryImageUpdating(image: uiImage, organizerId: organizerId, photoId: photoId, userID: user.id, tocken: tocken, boundary: boundary)
        let request = try await networkManager.request(endpoint: EditPlaceEndPoints.updateLibraryPhoto, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ImageResult.self, with: request)
        guard decodedResult.result, let url = decodedResult.url else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return url
    }
    
    func deleteLibraryPhoto(organizerId: Int, photoId: String, from user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters: [String: Any] = [
            "organizer_id": organizerId,
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

extension EditOrganizerNetworkManager {
    private func createBodyImageUpdating(image: UIImage, organizerId: Int, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        //place_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"organizer_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(organizerId)\r\n".data(using: .utf8)!)
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
    
    private func createBodyLibraryImageUpdating(image: UIImage, organizerId: Int, photoId: String, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // place_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"organizer_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(organizerId)\r\n".data(using: .utf8)!)
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
