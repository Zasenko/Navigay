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
        case places
        case events
        case region
    }

    
    let id: Int
    let name: String
    let smallPhoto: String?
    let photo: String?
    let photos: [String]?
    let lastUpdate: String
    
    let about: String?
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
    let region: DecodedRegion?
}
