//
//  AdminCountries.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import Foundation

struct AdminCountriesResult: Codable {
    let result: Bool
    let error: ApiError?
    let countries: [AdminCountry]?
}
