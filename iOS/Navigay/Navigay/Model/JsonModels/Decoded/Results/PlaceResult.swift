//
//  PlaceResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 17.11.23.
//

import Foundation

struct PlaceResult: Codable {
    let result: Bool
    let error: ApiError?
    let place: DecodedPlace?
}
