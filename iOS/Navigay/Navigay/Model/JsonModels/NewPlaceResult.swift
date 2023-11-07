//
//  NewPlaceResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import Foundation

struct NewPlaceResult: Codable {
    let result: Bool
    let error: ApiError?
    let placeId: Int?
}
