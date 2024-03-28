//
//  AdminCountry.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCountry: Identifiable, Codable {
    let id: Int
    let isoCountryCode: String
    let nameOrigin: String?
    let nameEn: String?
    let about: String?
    let flagEmoji: String?
    let photo: String?
    let showRegions: Bool?
    let isActive: Bool
    let isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, isoCountryCode, photo, about
        case nameOrigin = "name_origin"
        case nameEn = "name_en"
        case flagEmoji = "flag_emoji"
        case showRegions = "show_regions"
        case isActive = "is_active"
        case isChecked = "is_checked"
    }
}
