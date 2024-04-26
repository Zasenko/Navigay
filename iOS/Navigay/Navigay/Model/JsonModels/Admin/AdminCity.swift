//
//  AdminCity.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCity: Identifiable, Codable {
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
    let isCapital: Bool?
    let isGayParadise: Bool?
    let redirectCityId: Int?
    let isActive: Bool
    let isChecked: Bool
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, about, photo, photos, latitude, longitude
        case countryId = "country_id"
        case regionId = "region_id"
        case nameOrigin = "name_origin_en"
        case nameEn = "name_en"
        case isCapital = "is_capital"
        case isGayParadise = "is_gay_paradise"
        case redirectCityId = "redirect_city_id"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case userId = "user_id"
    }
}
