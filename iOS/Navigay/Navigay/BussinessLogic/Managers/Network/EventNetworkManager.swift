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
    func fetchEvent(id: Int) async -> DecodedEvent?
    func addNewEvent(event: NewEvent) async throws -> NewEventResult
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage) async throws -> PosterResult
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
    
    // todo private
    func addToLoadedEvents(id: Int) {
        loadedEvents.append(id)
    }
    
    func fetchEvent(id: Int) async -> DecodedEvent? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
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
            guard let decodedResult = try? JSONDecoder().decode(EventResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            
            guard decodedResult.result, let decodedEvent = decodedResult.event else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - EventNetworkManager fetchEvent(id: \(id)) - ", decodedResult.error?.message ?? "")
                return nil
            }
            addToLoadedEvents(id: decodedEvent.id)
            return decodedEvent
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - EventNetworkManager fetchEvent(id: \(id)) - ", error)
            return nil
        }
    }
    
    func addNewEvent(event: NewEvent) async throws -> NewEventResult {
        let path = "/api/event/add-new-event.php"
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
            let jsonData = try JSONEncoder().encode(event)
            request.httpBody = jsonData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(NewEventResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func updatePoster(eventId: Int, poster: UIImage, smallPoster: UIImage) async throws -> PosterResult {
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
            request.httpBody = try await createBodyPosterUpdating(poster: poster, smallPoster: smallPoster, eventId: eventId, boundary: boundary)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(PosterResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            return decodedResult
        } catch {
            throw error
        }
    }
}

extension EventNetworkManager {
    private func createBodyPosterUpdating(poster: UIImage, smallPoster: UIImage, eventId: Int, boundary: String) async throws -> Data {
        var body = Data()
        guard let posterData = poster.jpegData(compressionQuality: 0.8), let smallPosterData = smallPoster.jpegData(compressionQuality: 0.8) else {
            throw NetworkErrors.imageDataError
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"event_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(eventId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(posterData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"small_poster\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(smallPosterData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
