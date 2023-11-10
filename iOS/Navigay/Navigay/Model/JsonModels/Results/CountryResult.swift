//
//  CountryResult.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 14.09.23.
//

import Foundation

struct CountryResult: Codable {
    let result: Bool
    let error: ApiError?
    let country: DecodedCountry?
}
