//
//  DecodedCountry.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

struct DecodedCountry: Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case isoCountryCode
        case name
        case flagEmoji = "flag_emoji"
        case photo
        case showRegions = "show_regions"
        case isActive = "is_active"
        case lastUpdate = "updated_at"
        case about
        case regions
    }
    
    let id: Int
    let isoCountryCode: String
    let name: String
    let flagEmoji: String
    let photo: String
    let showRegions: Bool
    let isActive: Bool
    let lastUpdate: String
    
    let about: String?
    let regions: [DecodedRegion]?
}
