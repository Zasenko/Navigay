//
//  EditEventNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.03.24.
//

import SwiftUI

enum EditEventEndPoints {
    case fetchEvent
    case addNewEvent
    case addPosterToEvents
    case updateTitleAndType
    case updateAbout
    case updateAdditionalInformation
    case updateActivity
    case updateTime
    case updateFee
    case updatePoster
    case deletePoster
    case deleteEvent
}

extension EditEventEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .fetchEvent:
            return "/api/admin/get-event.php"
        case .addNewEvent:
            return "/api/event/add-new-event.php"
        case .addPosterToEvents:
            return "/api/event/add-new-poster.php"
        case .updateTitleAndType:
            return "/api/event/update-title-and-type.php"
        case .updateAbout:
            return "/api/event/update-about.php"
        case .updateAdditionalInformation:
            return "/api/event/update-additional-information.php"
        case .updateActivity:
            return "/api/event/update-activity.php"
        case .updateTime:
            return "/api/event/update-time.php"
        case .updateFee:
            return "/api/event/update-fee.php"
        case .updatePoster:
            return "/api/event/update-poster.php"
        case .deletePoster:
            return "/api/event/delete-poster.php"
        case .deleteEvent:
            return "/api/event/delete-event.php"
        }
    }
}

protocol EditEventNetworkManagerProtocol {
    var networkManager: NetworkManagerProtocol {get}
    func fetchEvent(id: Int, for user: AppUser) async throws -> AdminEvent
    func addNewEvent(event: NewEvent) async throws -> [Int]
    func addPosterToEvents(with ids: [Int], poster: UIImage, smallPoster: UIImage, from user: AppUser) async throws
    func updateTitleAndType(id: Int, name: String, type: EventType, user: AppUser) async throws
    func updateAbout(id: Int, about: String?, user: AppUser) async throws
    func updateAdditionalInformation(id: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, tags: [Tag]?, user: AppUser) async throws
    func updateActivity(id: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws
    func updateTime(id: Int, startDate: Date, startTime: Date?, finishDate: Date?, finishTime: Date?, user: AppUser) async throws
    func updateFee(id: Int, isFree: Bool, tickets: String?, fee: String?, user: AppUser) async throws
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage, from user: AppUser) async throws -> PosterUrls
    func deletePoster(eventId: Int, from user: AppUser) async throws
    func deleteEvent(eventId: Int, from user: AppUser) async throws
}

final class EditEventNetworkManager {

    // MARK: - Private Properties
    
    let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - CountryNetworkManagerProtocol

extension EditEventNetworkManager: EditEventNetworkManagerProtocol {
    
    func fetchEvent(id: Int, for user: AppUser) async throws -> AdminEvent {
        debugPrint("-AdminNetworkManager- fetchEvent id \(id)")
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.fetchEvent, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: AdminEventResult.self, with: request)
        guard decodedResult.result, let decodedEvent = decodedResult.event else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedEvent
    }
    
    func addNewEvent(event: NewEvent) async throws -> [Int] {
        let body = try JSONEncoder().encode(event)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.addNewEvent, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: NewEventResult.self, with: request)
        guard decodedResult.result,
              let ids = decodedResult.ids,
              !ids.isEmpty else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return ids
    }
    
    func addPosterToEvents(with ids: [Int], poster: UIImage, smallPoster: UIImage, from user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyEventsPosterUpdating(poster: poster, smallPoster: smallPoster, boundary: boundary, eventIDs: ids, addedBy: user.id, tocken: tocken)
        let request = try await networkManager.request(endpoint: EditEventEndPoints.addPosterToEvents, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateTitleAndType(id: Int, name: String, type: EventType, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "name": name,
            "type": String(type.rawValue),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateTitleAndType, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateTime(id: Int, startDate: Date, startTime: Date?, finishDate: Date?, finishTime: Date?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "start_date": startDate.format("yyyy-MM-dd"),
            "start_time": startTime?.format("HH:mm"),
            "finish_date": finishDate?.format("yyyy-MM-dd"),
            "finish_time": finishTime?.format("HH:mm"),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateTime, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateFee(id: Int, isFree: Bool, tickets: String?, fee: String?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "is_free": isFree ? "1" : "0",
            "tickets": tickets,
            "fee": fee,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateFee, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    
    func updateAdditionalInformation(id: Int, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, tags: [Tag]?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        var parameters = [
            "event_id": String(id),
            "user_id": String(user.id),
            "session_key": tocken,
            "email": email,
            "phone": phone,
            "www": www,
            "facebook": facebook,
            "instagram": instagram,
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
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateAdditionalInformation, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateAbout(id: Int, about: String?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "about": about,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateAbout, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updateActivity(id: Int, isActive: Bool, isChecked: Bool, adminNotes: String?, user: AppUser) async throws {
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(id),
            "is_active": isActive ? "1" : "0",
            "is_checked": isChecked ? "1" : "0",
            "admin_notes": adminNotes,
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updateActivity, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage, from user: AppUser) async throws -> PosterUrls {
        let tocken = try networkManager.getTocken(email: user.email)
        let boundary = UUID().uuidString
        let headers = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let body = try await createBodyPosterUpdating(poster: poster, smallPoster: smallPoster, eventId: eventId, userID: user.id, tocken: tocken, boundary: boundary)
        
        let request = try await networkManager.request(endpoint: EditEventEndPoints.updatePoster, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: PosterResult.self, with: request)
        guard decodedResult.result, let posterUrls = decodedResult.poster else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return posterUrls
    }
    
    func deletePoster(eventId: Int, from user: AppUser) async throws {
        debugPrint("-EventNetworkManager- deletePoster eventId: \(eventId)")
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(eventId),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.deletePoster, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func deleteEvent(eventId: Int, from user: AppUser) async throws {
        debugPrint("-EventNetworkManager- deleteEvent eventId: \(eventId)")
        let tocken = try networkManager.getTocken(email: user.email)
        let parameters = [
            "event_id": String(eventId),
            "user_id": String(user.id),
            "session_key": tocken,
        ]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: EditEventEndPoints.deleteEvent, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}

// MARK: - Private Functions

extension EditEventNetworkManager {
    private func createBodyPosterUpdating(poster: UIImage, smallPoster: UIImage, eventId: Int, userID: Int, tocken: String, boundary: String) async throws -> Data {
        var body = Data()
        guard let posterData = poster.jpegData(compressionQuality: 0.8), let smallPosterData = smallPoster.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // event_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"event_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(eventId)\r\n".data(using: .utf8)!)
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
        // poster
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(posterData)
        body.append("\r\n".data(using: .utf8)!)
        // small_poster
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"small_poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(smallPosterData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func createBodyEventsPosterUpdating(poster: UIImage, smallPoster: UIImage, boundary: String, eventIDs: [Int], addedBy: Int, tocken: String) async throws -> Data {
        var body = Data()
        guard let posterData = poster.jpegData(compressionQuality: 0.8), let smallPosterData = smallPoster.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // events_ids
        for eventID in eventIDs {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"events_ids[]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(eventID)\r\n".data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        // added_by
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"added_by\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(addedBy)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // sessyin_key
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(tocken)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // poster
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(posterData)
        body.append("\r\n".data(using: .utf8)!)
        // small_poster
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"small_poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(smallPosterData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
