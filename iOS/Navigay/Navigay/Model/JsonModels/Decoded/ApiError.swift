//
//  ApiError.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

struct ApiError: Codable {
    let show: Bool
    let message: String
}
