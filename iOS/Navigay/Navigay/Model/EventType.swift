//
//  EventType.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import Foundation

enum EventType: Int, Codable, CaseIterable {
    case other = 0,
         party = 1,
         birthday = 2,
         festival = 3,
         pride = 4
    
    func getName() -> String {
        switch self {
        case .other:
            return "other"
        case .party:
            return "party"
        case .pride:
            return "pride"
        case .festival:
            return "festival"
        case .birthday:
            return "birthday"
        }
    }
}
