//
//  Language.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import Foundation

enum Language: String, CaseIterable {
    
    case en, de, es, it, fr, ru
    
    func getFlag() -> String {
        switch self {
        case .en:
            return "🇬🇧"
        case .de:
            return "🇩🇪"
        case .ru:
            return "🇷🇺"
        case .es:
            return "🇪🇸"
        case .it:
            return "🇮🇹"
        case .fr:
            return "🇫🇷"
        }
    }
    
    func getName() -> String {
        switch self {
        case .en:
            return "English"
        case .de:
            return "Deutsch"
        case .ru:
            return "Русский"
        case .es:
            return "Español"
        case .it:
            return "Italiano"
        case .fr:
            return "Français"
        }
    }
}
