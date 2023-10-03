//
//  UserAccessRights.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import Foundation

enum UserAccessRights: String, Codable {
    case user, admin, moderator, partner, anonim, blocked
}
