//
//  AdminRegionResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 28.03.24.
//

import Foundation

struct AdminRegionResult: Codable {
    let result: Bool
    let error: ApiError?
    let region: AdminRegion?
}
