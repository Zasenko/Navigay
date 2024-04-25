//
//  AdminCity.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCity: Identifiable, Codable, Hashable  {
    
    let id: Int
    let countryId: Int
    let regionId: Int
    let latitude: Double?
    let longitude: Double?
    let nameOrigin: String?
    let nameEn: String?
    let about: String?
    let photo: String?
    let photos: [DecodedPhoto]?
    let isActive: Bool
    let isChecked: Bool
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, about, photo, photos, latitude, longitude
        case countryId = "country_id"
        case regionId = "region_id"
        case nameOrigin = "name_origin_en"
        case nameEn = "name_en"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case userId = "user_id"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdminCity, rhs: AdminCity) -> Bool {
        return lhs.id == rhs.id
    }
}
