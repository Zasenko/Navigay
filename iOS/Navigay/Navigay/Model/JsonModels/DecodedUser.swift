//
//  DecodedUser.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import Foundation

struct DecodedAppUser: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let status: UserAccessRights
    let bio: String?
    let photo: String?
    let instagram: String?
    let likedPlacesId: [Int]?
}

struct DecodedUser: Codable, Identifiable {
    let id: Int
    let name: String
    let bio: String?
    let photo: String?
    let instagram: String?
}
