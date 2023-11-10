//
//  DecodedPhoto.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct DecodedPhoto: Identifiable, Codable {
    let id: UUID
    let url: String
}
