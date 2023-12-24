//
//  AroundResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.11.23.
//

import Foundation

struct AroundResult: Codable {
    let result: Bool
    let error: ApiError?
    let items: ItemsResult?
}
