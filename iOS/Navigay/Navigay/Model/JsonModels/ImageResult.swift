//
//  ImageResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.11.23.
//

import Foundation

struct ImageResult: Codable {
    let result: Bool
    let url: String?
    let error: ApiError?
}
