//
//  AdminRegion.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminRegion: Identifiable, Codable {
    let id: Int
    let countryId: Int
    let nameOrigin: String?
    let nameEn: String?
    let nameFr: String?
    let nameDe: String?
    let nameRu: String?
    let nameIt: String?
    let nameEs: String?
    let namePt: String?
    let photo: String?
    let isActive: Bool
    let isChecked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, photo
        case countryId = "country_id"
        case nameOrigin = "name_origin"
        case nameEn = "name_en"
        case nameFr = "name_fr"
        case nameDe = "name_de"
        case nameRu = "name_ru"
        case nameIt = "name_it"
        case nameEs = "name_es"
        case namePt = "name_pt"
        case isActive = "is_active"
        case isChecked = "is_checked"
    }
}
