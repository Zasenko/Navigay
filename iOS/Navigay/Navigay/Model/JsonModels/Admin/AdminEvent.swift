//
//  AdminEvent.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.03.24.
//

import Foundation

struct AdminEventPreview: Identifiable, Codable {
    let id: Int
    let name: String
    let type: EventType
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type = "type_id"
    }
}

struct AdminEvent: Identifiable, Codable {
    
    let id: Int
    let name: String
    let type: EventType
    let countryId: Int
    let regionId: Int?
    let cityId: Int?
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let startDate: String
    let startTime: String?
    let finishDate: String?
    let finishTime: String?
    let location: String?
    let about: String?
    let poster: String?
    let smallPoster: String?
    let isFree: Bool
    let tickets: String?
    let fee: String?
    let email: String?
    let phone: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let tags: [Tag]?
    let ownerId: Int?
    let placeId: Int?
    let addedBy: Int?
    let adminNotes: String?
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
        case latitude
        case longitude
        case address
        case startDate = "start_date"
        case startTime = "start_time"
        case finishDate = "finish_date"
        case finishTime = "finish_time"
        case location
        case about
        case poster
        case smallPoster = "poster_small"
        case isFree = "is_free"
        case tickets
        case fee
        case email
        case phone
        case www
        case facebook
        case instagram
        case tags
        case ownerId = "owner_id"
        case placeId = "place_id"
        case addedBy = "added_by"
        case adminNotes = "admin_notes"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
