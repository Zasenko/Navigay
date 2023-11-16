//
//  PosterResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.11.23.
//

import Foundation

struct PosterResult: Codable {
    let result: Bool
    let posterUrl: String?
    let smallPosterUrl: String?
    let error: ApiError?
    
    enum CodingKeys: String, CodingKey {
        case result, error
        case posterUrl = "poster_url"
        case smallPosterUrl = "small_poster_url"
    }
}
