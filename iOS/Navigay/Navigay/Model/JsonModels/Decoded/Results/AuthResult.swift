//
//  AuthResult.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import Foundation

struct AuthResult: Codable {
    let result: Bool
    let error: ApiError?
    let user: DecodedAppUser?
}
