//
//  AdminCitiesResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.04.24.
//

import Foundation

struct AdminCitiesResult: Codable {
    let result: Bool
    let error: ApiError?
    let cities: [AdminCity]?
}
