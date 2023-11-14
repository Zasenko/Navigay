//
//  CountriesResult.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

struct CountriesResult: Codable {
    let result: Bool
    let error: ApiError?
    let countries: [DecodedCountry]?
}
