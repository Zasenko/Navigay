//
//  DecodedCity.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedCity: Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case smallPhoto = "small_photo"
        case photo
        case lastUpdate = "updated_at"
        case about
        case photos
        case latitude
        case longitude
        case isCapital = "is_capital"
        case isGayParadise = "is_gay_paradise"
        case places
        case events
        case region
        case regionId = "region_id"
        case placesCount = "place_count"
        case eventsCount = "event_count"
    }

    let id: Int
    let name: String
    let smallPhoto: String?
    let photo: String?
    let photos: [String]?
    let latitude: Double
    let longitude: Double
    let isCapital: Bool
    let isGayParadise: Bool
    let lastUpdate: String
    
    let about: String?
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
    let regionId: Int?
    let region: DecodedRegion?
    let placesCount: Int?
    let eventsCount: Int?
}
