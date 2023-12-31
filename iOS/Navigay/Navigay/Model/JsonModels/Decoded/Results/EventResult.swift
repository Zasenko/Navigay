//
//  EventResult.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 28.09.23.
//

import Foundation

struct EventResult: Codable {
    let result: Bool
    let error: ApiError?
    let event: DecodedEvent?
}
