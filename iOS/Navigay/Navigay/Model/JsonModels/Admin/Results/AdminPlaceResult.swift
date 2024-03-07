//
//  AdminPlaceResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.01.24.
//

import Foundation

struct AdminPlaceResult: Codable {
    let result: Bool
    let error: ApiError?
    let place: AdminPlace?
}
