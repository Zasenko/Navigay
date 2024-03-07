//
//  PosterResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 14.11.23.
//

import Foundation

struct PosterResult: Codable {
    let result: Bool
    let poster: PosterUrls?
    let error: ApiError?
}

struct PosterUrls: Codable {
    let posterUrl: String
    let smallPosterUrl: String
    
    enum CodingKeys: String, CodingKey {
        case posterUrl = "poster_url"
        case smallPosterUrl = "small_poster_url"
    }
}
