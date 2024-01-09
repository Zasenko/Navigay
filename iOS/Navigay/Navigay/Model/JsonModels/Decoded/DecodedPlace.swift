//
//  DecodedPlace.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation
struct DecodedPlace: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type = "type_id"
        case address
        case latitude
        case longitude
        case isActive = "is_active"
        case lastUpdate = "updated_at"
        case avatar
        case mainPhoto = "main_photo"
        case photos
        case tags
        case timetable
        case about
        case www, facebook, instagram, phone
        case otherInfo = "other_info"
        case city
        case events
    }

    let id: Int
    let name: String
    let type: PlaceType
    let address: String
    let latitude: Double
    let longitude: Double
    let isActive: Bool
    let lastUpdate: String
    
    let avatar: String?
    let mainPhoto: String?
    let photos: [String]?
    let tags: [Tag]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let about: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let phone: String?
    let city: DecodedCity?
    let events: [DecodedEvent]?
}

struct PlaceWorkDay: Codable {
    let day: DayOfWeek
    let opening: String
    let closing: String
}

struct About: Codable {
    let language: Language
    let about: String
}
