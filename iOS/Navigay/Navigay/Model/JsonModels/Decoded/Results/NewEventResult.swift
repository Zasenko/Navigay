//
//  NewEventResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import Foundation

struct NewEventResult: Codable {
    let result: Bool
    let error: ApiError?
    let id: Int?
}
