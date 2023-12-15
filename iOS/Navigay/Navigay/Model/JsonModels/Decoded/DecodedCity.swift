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
        case photo
        case isActive = "is_active"
        case lastUpdate = "updated_at"
        case about
        case places
        case events
    }

    
    let id: Int
    let name: String
    let photo: String
    let isActive: Bool
    let lastUpdate: String
    
    let about: String?
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
}
