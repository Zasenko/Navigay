//
//  DecodedRegion.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedRegion: Identifiable, Codable {
    let id: Int
    let name: String?
    let isActive: Bool
    let cities: [DecodedCity]
}
