//
//  EventsResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.06.24.
//

import Foundation

struct EventsResult: Codable {
    let result: Bool
    let error: ApiError?
    let events: [DecodedEvent]?
    let cities: [DecodedCity]?
}
