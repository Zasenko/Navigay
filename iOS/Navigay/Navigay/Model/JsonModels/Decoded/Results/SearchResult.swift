//
//  SearchResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.01.24.
//

import Foundation

struct SearchResult: Codable {
    let result: Bool
    let error: ApiError?
    let items: SearchItems?
}

struct SearchItems: Codable {
    let cities: [DecodedCity]?
    let regions: [DecodedRegion]?
    let places: [DecodedPlace]?
    let events: [DecodedEvent]?
}
