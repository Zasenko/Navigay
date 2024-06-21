//
//  EventNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 28.09.23.
//

import Foundation

enum EventEndPoints {
    case fetchEvent(id: Int)
    case fetchEvents(ids: [Int])
    case fetchEventsForCity(cityId: Int, date: Date)
    case fetchEventsForPlace(placeId: Int, date: Date)
    case sendComplaint
}

extension EventEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        components.queryItems = queryItems()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .fetchEvent:
            return "/api/event/get-event.php"
        case .fetchEvents:
            return "/api/event/get-events.php"
        case .fetchEventsForCity:
            return "/api/event/get-events-for-city-by-date.php"
        case .fetchEventsForPlace:
            return "/api/event/get-events-for-place-by-date.php"
        case .sendComplaint:
            return ""
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchEvent(let id):
            return [URLQueryItem(name: "event_id", value: String(id))]
        case .fetchEvents(let ids):
            return [URLQueryItem(name: "event_ids", value: ids.map(String.init).joined(separator: ","))]
        case .fetchEventsForCity(let cityId, let date):
            return [URLQueryItem(name: "city_id", value: String(cityId)),
                    URLQueryItem(name: "date", value: date.format("yyyy-MM-dd"))]
        case .fetchEventsForPlace(let placeId, let date):
            return [URLQueryItem(name: "place_id", value: String(placeId)),
                    URLQueryItem(name: "date", value: date.format("yyyy-MM-dd"))]
        default:
            return nil
        }
    }
}

protocol EventNetworkManagerProtocol {
    var loadedEvents: [Int] { get } // TODO!!!
    var loadedCalendarEventsId: [Int] { get } // TODO!!!
    func fetchEvent(id: Int) async throws -> DecodedEvent
    func fetchEvents(ids: [Int]) async throws -> DecodedSearchItems
    func fetchEvents(cityId: Int, date: Date) async throws -> [DecodedEvent]
    func fetchEvents(placeId: Int, date: Date) async throws -> [DecodedEvent]
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws
}

final class EventNetworkManager {
    
    // MARK: - Propertie
    
    // TODO!!!
    var loadedEvents: [Int] = []
    var loadedCalendarEventsId: [Int] = []

    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension EventNetworkManager: EventNetworkManagerProtocol {
    
    func sendComplaint(eventId: Int, user: AppUser, reason: String) async throws {
        
    }
    
    func fetchEvent(id: Int) async throws -> DecodedEvent {
        debugPrint("--- fetchEvent(id: \(id)")
        let request = try await networkManager.request(endpoint: EventEndPoints.fetchEvent(id: id), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: EventResult.self, with: request)
        guard decodedResult.result, let decodedEvent = decodedResult.event else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedEvents.append(decodedEvent.id) // TODO!!!
        return decodedEvent
    }
    
    func fetchEvents(ids: [Int]) async throws -> DecodedSearchItems {
        debugPrint("--- fetchEvents(ids: \(ids))")
        let request = try await networkManager.request(endpoint: EventEndPoints.fetchEvents(ids: ids), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: SearchResult.self, with: request)
        guard decodedResult.result, let decodedItems = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedItems.events?.forEach( { loadedCalendarEventsId.append($0.id) } )  // TODO!!!
        return decodedItems
    }
    
    func fetchEvents(cityId: Int, date: Date) async throws -> [DecodedEvent] {
        debugPrint("--- fetchEvents(cityId: \(cityId), date: \(date)")
        let request = try await networkManager.request(endpoint: EventEndPoints.fetchEventsForCity(cityId: cityId, date: date), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: EventsResult.self, with: request)
        guard decodedResult.result, let decodedEvents = decodedResult.events else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedEvents.forEach( { loadedCalendarEventsId.append($0.id) } )  // TODO!!!
        return decodedEvents
    }
    
    func fetchEvents(placeId: Int, date: Date) async throws -> [DecodedEvent] {
        debugPrint("--- fetchEvents(placeId: \(placeId), date: \(date)")
        let request = try await networkManager.request(endpoint: EventEndPoints.fetchEventsForPlace(placeId: placeId, date: date), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: EventsResult.self, with: request)
        guard decodedResult.result, let decodedEvents = decodedResult.events else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        decodedEvents.forEach( { loadedCalendarEventsId.append($0.id) } )  // TODO!!!
        return decodedEvents
    }
}
