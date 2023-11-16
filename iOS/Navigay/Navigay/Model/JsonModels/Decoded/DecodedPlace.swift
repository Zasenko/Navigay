//
//  DecodedPlace.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedPlace: Identifiable, Codable {

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
    let tags: [Tag]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let about: [About]?
    let email: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let phone: String?

    let countryId: Int?
    let regionId: Int?
    let cityId: Int?
    
    let ownerId: Int?
    let isChecked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, avatar, tags, timetable, about, email, www, facebook, instagram, phone
        case type = "type_id"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case lastUpdate = "updated_at"
        case mainPhoto = "main_photo"
        case otherInfo = "other_info"
        case countryId = "country_id"
        case regionId = "region_id"
        case cityId = "city_id"
        case ownerId = "owner_id"
    }
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
