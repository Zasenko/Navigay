//
//  ItemsResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.12.23.
//

import Foundation

struct ItemsResult: Codable {
    enum CodingKeys: String, CodingKey {
        case foundAround = "found_around"
        case places
        case events
    }
    
    let foundAround: Bool
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
}
