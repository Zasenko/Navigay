//
//  DecodedCountry.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

struct DecodedCountry: Identifiable, Codable {
    let id: Int
    let isoCountryCode: String
    let name: String
    let flagEmoji: String
    let photo: String
    let showRegions: Bool
    let isActive: Bool
    
    let about: String?
    let regions: [DecodedRegion]?
}
