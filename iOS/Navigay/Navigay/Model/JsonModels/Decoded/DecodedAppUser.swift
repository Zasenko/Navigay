//
//  DecodedAppUser.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.02.24.
//

import Foundation

struct DecodedAppUser: Codable, Identifiable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case status
        case bio
        case photo
        case sessionKey = "session_key"
    }
    
    let id: Int
    let name: String
    let email: String
    let status: UserAccessRights
    let sessionKey: String
    let bio: String?
    let photo: String?
}
