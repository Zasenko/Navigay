//
//  AdminRegion.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminRegion: Identifiable, Codable {
    let id: Int
    let countryId: Int
    let nameOrigin: String?
    let nameEn: String?
    let photo: String?
    let isActive: Bool
    let isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, photo
        case countryId = "country_id"
        case nameOrigin = "name_origin_en"
        case nameEn = "name_en"
        case isActive = "is_active"
        case isChecked = "is_checked"
    }
}
