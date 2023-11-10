//
//  DecodedPlace.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedPlace: Identifiable, Codable {

    let id: Int
    let name: String
    let type: PlaceType
    let address: String
    let latitude: Double
    let longitude: Double
    let isActive: Bool
    let lastUpdate: String
    
    let photoSmall: String?
    let photoLarge: String?
    let tags: [Tag]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let about: [About]?
    let email: String?
    let www: String?
    let fb: String?
    let insta: String?
    let phone: String?

    let countryId: Int?
    let regionId: Int?
    let cityId: Int?
    
    let ownerId: Int?
}

struct PlaceWorkDay: Codable {
    let day: DayOfWeek
    let opening: String
    let closing: String
}

struct About: Codable {
    let language: Language
    let about: String
}
