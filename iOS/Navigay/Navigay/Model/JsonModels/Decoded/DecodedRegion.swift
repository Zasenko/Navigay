//
//  DecodedRegion.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedRegion: Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photo
        case lastUpdate = "updated_at"
        case cities
        case country
    }
    
    let id: Int
    let name: String?
    let photo: String?
    let lastUpdate: String
    let cities: [DecodedCity]?
    let country: DecodedCountry?
}
