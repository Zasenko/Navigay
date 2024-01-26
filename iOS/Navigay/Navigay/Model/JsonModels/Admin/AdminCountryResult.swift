//
//  AdminCountryResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.01.24.
//

import Foundation

struct AdminCountryResult: Codable {
    let result: Bool
    let error: ApiError?
    let country: AdminCountry?
}
