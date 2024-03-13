//
//  AdminEventResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.03.24.
//

import Foundation

struct AdminEventResult: Codable {
    let result: Bool
    let error: ApiError?
    let event: AdminEvent?
}
