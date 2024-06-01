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
    let items: DecodedSearchItems?
}

struct DecodedSearchItems: Codable {
    let places: [DecodedPlace]
    let events: [DecodedEvent]
    let cities: [DecodedCity]
    let regions: [DecodedRegion]
    let countries: [DecodedCountry]
}


