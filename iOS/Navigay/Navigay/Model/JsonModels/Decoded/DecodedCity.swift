//
//  DecodedCity.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedCity: Identifiable, Codable {
    let id: Int
    let name: String
    let photo: String
    let isActive: Bool
    
    let about: String?
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
}
