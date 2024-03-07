//
//  AdminCityResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import Foundation

struct AdminCityResult: Codable {
    let result: Bool
    let error: ApiError?
    let city: AdminCity?
}
