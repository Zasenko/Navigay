//
//  NewPlace.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 06.11.23.
//

import Foundation

struct NewPlace: Codable {
    
    let name: String
    let type: Int
    let isoCountryCode: String
    let countryOrigin: String?
    let countryEnglish: String?
    let regionOrigin: String?
    let regionEnglish: String?
    let cityOrigin: String?
    let cityEnglish: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let about: [PlaceAboutForSend]?
    let tags: [Int]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let email: String?
    let phone: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let ownerId: Int?
    
    init(name: String, type: Int, isoCountryCode: String, countryOrigin: String?, countryEnglish: String?, regionOrigin: String?, regionEnglish: String?, cityOrigin: String?, cityEnglish: String?, address: String, latitude: Double, longitude: Double, about: [PlaceAboutForSend]?, tags: [Int]?, timetable: [PlaceWorkDay]?, otherInfo: String?, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, ownerId: Int?) {
        self.name = name
        self.type = type
        self.isoCountryCode = isoCountryCode
        self.countryOrigin = countryOrigin
        self.countryEnglish = countryEnglish
        self.regionOrigin = regionOrigin
        self.regionEnglish = regionEnglish
        self.cityOrigin = cityOrigin
        self.cityEnglish = cityEnglish
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.about = about
        self.tags = tags
        self.timetable = timetable
        self.otherInfo = otherInfo
        self.email = email
        self.phone = phone
        self.www = www
        self.facebook = facebook
        self.instagram = instagram
        self.ownerId = ownerId
    }
}
