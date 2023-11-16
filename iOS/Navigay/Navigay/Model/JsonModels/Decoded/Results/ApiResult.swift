//
//  ApiResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 09.11.23.
//

import Foundation

struct ApiResult: Codable {
    let result: Bool
    let error: ApiError?
}
