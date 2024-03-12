//
//  EventNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 28.09.23.
//

import SwiftUI

protocol EventNetworkManagerProtocol {
    var loadedEvents: [Int] { get set }
    func addToLoadedEvents(id: Int)
    func fetchEvent(id: Int) async throws -> DecodedEvent
    func addNewEvent(event: NewEvent) async throws -> [Int]
    func addPosterToEvents(with ids: [Int], poster: UIImage, smallPoster: UIImage, addedBy: Int, sessionKey: String) async throws
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage, user: AppUser) async throws -> PosterUrls
    func deletePoster(eventId: Int, user: AppUser) async throws
    func deleteEvent(eventId: Int, user: AppUser) async throws
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws
}

final class EventNetworkManager {
    
    // MARK: - Propertie
    
    var loadedEvents: [Int] = []
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(appSettingsManager: AppSettingsManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension EventNetworkManager: EventNetworkManagerProtocol {
    
    func deletePoster(eventId: Int, user: AppUser) async throws {
        debugPrint("-EventNetworkManager- deletePoster eventId: \(eventId)")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/event/delete-poster.php"
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
        let parameters = [
            "event_id": String(eventId),
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
        guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func deleteEvent(eventId: Int, user: AppUser) async throws {
        debugPrint("-EventNetworkManager- deleteEvent eventId: \(eventId)")
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/event/delete-event.php"
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
        let parameters = [
            "event_id": String(eventId),
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
        guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws {
        
    }
    
    
    // todo private
    func addToLoadedEvents(id: Int) {
        loadedEvents.append(id)
    }
    
    func fetchEvent(id: Int) async throws -> DecodedEvent {
        debugPrint("--- fetchEvent(id: \(id)")
        let path = "/api/event/get-event.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "event_id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(EventResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedEvent = decodedResult.event else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        addToLoadedEvents(id: decodedEvent.id)
        return decodedEvent
    }
    
    func addNewEvent(event: NewEvent) async throws -> [Int] {
        let path = "/api/event/add-new-event.php"
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
            let jsonData = try JSONEncoder().encode(event)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(NewEventResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result,
                  let ids = decodedResult.ids,
                  !ids.isEmpty else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
            return ids
        } catch {
            throw error
        }
    }
    
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage, user: AppUser) async throws -> PosterUrls {
        guard let sessionKey = user.sessionKey else {
            throw NetworkErrors.noSessionKey
        }
        let path = "/api/event/update-poster.php"
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
            request.httpBody = try await createBodyPosterUpdating(poster: poster, smallPoster: smallPoster, eventId: eventId, userID: user.id, sessionKey: sessionKey, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(PosterResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let posterUrls = decodedResult.poster else {
                throw NetworkErrors.apiError(decodedResult.error)
            }
            return posterUrls
        } catch {
            throw error
        }
    }
    
    func addPosterToEvents(with ids: [Int], poster: UIImage, smallPoster: UIImage, addedBy: Int, sessionKey: String) async throws {
        let path = "/api/event/add-new-poster.php"
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
            request.httpBody = try await createBodyEventsPosterUpdating(poster: poster, smallPoster: smallPoster, boundary: boundary, eventIDs: ids, addedBy: addedBy, sessionKey: sessionKey)
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
        } catch {
            throw error
        }
    }
}

extension EventNetworkManager {
    private func createBodyPosterUpdating(poster: UIImage, smallPoster: UIImage, eventId: Int, userID: Int, sessionKey: String, boundary: String) async throws -> Data {
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
        body.append("\(sessionKey)".data(using: .utf8)!)
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
    
    private func createBodyEventsPosterUpdating(poster: UIImage, smallPoster: UIImage, boundary: String, eventIDs: [Int], addedBy: Int, sessionKey: String) async throws -> Data {
        var body = Data()
        guard let posterData = poster.jpegData(compressionQuality: 0.8), let smallPosterData = smallPoster.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        // eventIDs
        for eventID in eventIDs {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"events_ids[]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(eventID)\r\n".data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }
        // addedBy
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"added_by\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(addedBy)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        // sessyinKey
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"session_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(sessionKey)".data(using: .utf8)!)
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
