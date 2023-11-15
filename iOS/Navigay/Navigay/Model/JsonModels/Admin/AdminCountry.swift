//
//  AdminCountry.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCountry: Identifiable, Codable {
    let id: Int
    let isoCountryCode: String
    let nameOrigin: String?
    let nameEn: String?
    let nameFr: String?
    let nameDe: String?
    let nameRu: String?
    let nameIt: String?
    let nameEs: String?
    let namePt: String?
    let about: [DecodedAbout]?
    let flagEmoji: String?
    let photo: String?
    let showRegions: Bool
    let isActive: Bool
    let isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, isoCountryCode, photo, about
        case nameOrigin = "name_origin"
        case nameEn = "name_en"
        case nameFr = "name_fr"
        case nameDe = "name_de"
        case nameRu = "name_ru"
        case nameIt = "name_it"
        case nameEs = "name_es"
        case namePt = "name_pt"
        case flagEmoji = "flag_emoji"
        case showRegions = "show_regions"
        case isActive = "is_active"
        case isChecked = "is_checked"
    }
}
