//
//  OrganizerResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import Foundation

struct OrganizerResult: Codable {
    let result: Bool
    let error: ApiError?
    let organizer: DecodedOrganizer?
}
