//
//  DecodedUser.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import Foundation

struct DecodedUser: Codable, Identifiable {
    let id: Int
    let name: String
    let bio: String?
    let photo: String?
}
