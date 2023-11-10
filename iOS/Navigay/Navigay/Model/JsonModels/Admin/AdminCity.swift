//
//  AdminCity.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCity: Identifiable, Codable {
    let id: Int
    let countryId: Int
    let regionId: Int
    let name: String?
    let nameEn: String?
    let nameFr: String?
    let nameDe: String?
    let nameRu: String?
    let nameIt: String?
    let nameEs: String?
    let namePt: String?
    let about: [DecodedAbout]?
    let photo: String?
    let photos: [DecodedPhoto]?
    let isActive: Bool
    let isChecked: Bool
    let lastUpdate: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, about, photo, photos
        case countryId = "country_id"
        case regionId = "region_id"
        case nameEn = "name_en"
        case nameFr = "name_fr"
        case nameDe = "name_de"
        case nameRu = "name_ru"
        case nameIt = "name_it"
        case nameEs = "name_es"
        case namePt = "name_pt"
        case isActive = "is_active"
        case isChecked = "is_checked"
        case lastUpdate = "updated_at"
    }
}
