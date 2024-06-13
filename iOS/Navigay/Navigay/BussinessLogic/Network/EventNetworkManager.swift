//
//  EventNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 28.09.23.
//

import SwiftUI

protocol EventNetworkManagerProtocol {
    var loadedEvents: [Int] { get }
    var loadedCalendarEventsId: [Int] { get }
    func fetchEvent(id: Int) async throws -> DecodedEvent
    func fetchEvents(ids: [Int]) async throws -> DecodedSearchItems
    func fetchEvents(cityId: Int, date: Date) async throws -> [DecodedEvent]
    func fetchEvents(placeId: Int, date: Date) async throws -> [DecodedEvent]
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws
}

final class EventNetworkManager {
    
    // MARK: - Propertie
    
    var loadedEvents: [Int] = []
    var loadedCalendarEventsId: [Int] = []

    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    private let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension EventNetworkManager: EventNetworkManagerProtocol {
    
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws {
        
    }
    
    func fetchEvent(id: Int) async throws -> DecodedEvent {
        debugPrint("--- fetchEvent(id: \(id)")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
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
            throw NetworkErrors.badUrl
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
        loadedEvents.append(decodedEvent.id)
        return decodedEvent
    }
    
    func fetchEvents(ids: [Int]) async throws -> DecodedSearchItems {
        debugPrint("--- fetchEvents(ids: \(ids))")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/event/get-events.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "event_ids", value: ids.map(String.init).joined(separator: ",")),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(SearchResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedItems.events?.forEach( { loadedCalendarEventsId.append($0.id) } )
        return decodedItems
    }
    
    func fetchEvents(cityId: Int, date: Date) async throws -> [DecodedEvent] {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/event/get-events-for-city-by-date.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "city_id", value: String(cityId)),
                //URLQueryItem(name: "language", value: self.appSettingsManager.language)
                URLQueryItem(name: "date", value: date.format("yyyy-MM-dd")),
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(EventsResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedEvents = decodedResult.events else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedEvents.forEach( { loadedCalendarEventsId.append($0.id) } )
        return decodedEvents
    }
    
    func fetchEvents(placeId: Int, date: Date) async throws -> [DecodedEvent] {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/event/get-events-for-place-by-date.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "place_id", value: String(placeId)),
                //URLQueryItem(name: "language", value: self.appSettingsManager.language)
                URLQueryItem(name: "date", value: date.format("yyyy-MM-dd")),
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(EventsResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedEvents = decodedResult.events else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedEvents.forEach( { loadedCalendarEventsId.append($0.id) } )
        return decodedEvents
    }
}
