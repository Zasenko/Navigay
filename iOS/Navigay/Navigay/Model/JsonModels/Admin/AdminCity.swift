//
//  AdminCity.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.11.23.
//

import Foundation

struct AdminCity: Identifiable, Codable, Hashable  {
    
    let id: Int
    let countryId: Int
    let regionId: Int
    let nameOrigin: String?
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
    
    enum CodingKeys: String, CodingKey {
        case id, about, photo, photos
        case countryId = "country_id"
        case regionId = "region_id"
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdminCity, rhs: AdminCity) -> Bool {
        return lhs.id == rhs.id
    }
}
