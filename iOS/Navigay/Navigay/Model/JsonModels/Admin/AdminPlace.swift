//
//  AdminPlace.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminPlace: Identifiable, Codable {
    
    let id: Int
    let name: String
    let type: PlaceType
    let countryId: Int?
    let regionId: Int?
    let cityId: Int?
    let about: String?
    let avatar: String?
    let mainPhoto: String?
    let photos: [DecodedPhoto]?
    let address: String
    let latitude: Double
    let longitude: Double
    let www: String?
    let facebook: String?
    let instagram: String?
    let phone: String?
    let email: String?
    let tags: [Tag]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let ownerId: Int?
    let addedBy: Int?
    let isActive: Bool
    let isChecked: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type = "type_id"
        case countryId = "country_id"
        case regionId = "region_id"
        case cityId = "city_id"
        case about
        case avatar
        case mainPhoto = "main_photo"
        case photos
        case address
        case latitude
        case longitude
        case www
        case facebook
        case instagram
        case phone
        case email
        case tags
        case timetable
        case otherInfo = "other_info"
        case ownerId = "owner_id"
        case addedBy = "added_by"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
