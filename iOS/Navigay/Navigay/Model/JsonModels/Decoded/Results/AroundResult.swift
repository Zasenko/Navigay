//
//  AroundResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.11.23.
//

import Foundation

struct AroundResult: Codable {
    let result: Bool
    let error: ApiError?
    let items: ItemsResult?
}

struct AroundResultNew: Codable {
    let result: Bool
    let error: ApiError?
    let items: AroundItemsResult?
}

struct AroundItemsResult: Codable {
    enum CodingKeys: String, CodingKey {
        case foundAround = "found_around"
        case places
        case events
        case cities
        case countries
        case regions
    }
    
    let foundAround: Bool
    let places: [DecodedPlace]?
    let events: EventsItemsResult?
    let cities: [DecodedCity]?
    let countries: [DecodedCountry]?
    let regions: [DecodedRegion]?
}

struct EventsItemsResult: Codable {
    let today: [DecodedEvent]?
    let upcoming: [DecodedEvent]?
    let allDates: [String: [Int]]?
    let calendarDates: [String]?
    let eventsCount: Int?
}

struct AroundItems {
    let places: [Place]
    let events: [Event]
    let cities: [City]
    let countries: [Country]
    let regions: [Region]
}

struct EventsItems {
    let today: [Event]
    let upcoming: [Event]
    let allDates: [Date: [Int]]
 //   let calendarDates: [Date]
    let count: Int
}
