//
//  AdminRegionsResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 17.04.24.
//

import Foundation

struct AdminRegionsResult: Codable {
    let result: Bool
    let error: ApiError?
    let regions: [AdminRegion]?
}
