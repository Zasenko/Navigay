//
//  CityResult.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct CityResult: Codable {
    let result: Bool
    let error: ApiError?
    let city: DecodedCity?
}
