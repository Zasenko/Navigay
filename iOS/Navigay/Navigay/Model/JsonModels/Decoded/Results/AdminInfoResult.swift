//
//  AdminInfoResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminInfoResult: Codable {
    let result: Bool
    let error: ApiError?
    let countries: [AdminCountry]?
    let regions: [AdminRegion]?
    let cities: [AdminCity]?
    let places: [AdminPlace]?
}
