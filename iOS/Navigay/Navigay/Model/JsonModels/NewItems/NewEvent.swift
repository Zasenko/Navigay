//
//  NewEvent.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.11.23.
//

import Foundation

struct NewEvent: Codable {
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
    let startDate: String
    let startTime: String?
    let finishDate: String?
    let finishTime: String?
    let location: String?
    let about: [DecodedAbout]?
    let isFree: Bool
    let tickets: String?
    let fee: String?
    let email: String?
    let phone: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let tags: [Int]?
    let ownderId: Int?
    let placeId: Int?
    let addedBy: Int?
    let isActive: Bool
    let isChecked: Bool
    
    init(name: String, type: Int, isoCountryCode: String, countryOrigin: String?, countryEnglish: String?, regionOrigin: String?, regionEnglish: String?, cityOrigin: String?, cityEnglish: String?, address: String, latitude: Double, longitude: Double, startDate: String, startTime: String?, finishDate: String?, finishTime: String?, location: String?, about: [DecodedAbout]?, isFree: Bool, tickets: String?, fee: String?, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, tags: [Int]?, ownderId: Int?, placeId: Int?, addedBy: Int?, isActive: Bool, isChecked: Bool) {
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
        self.startDate = startDate
        self.startTime = startTime
        self.finishDate = finishDate
        self.finishTime = finishTime
        self.location = location
        self.about = about
        self.isFree = isFree
        self.tickets = tickets
        self.fee = fee
        self.email = email
        self.phone = phone
        self.www = www
        self.facebook = facebook
        self.instagram = instagram
        self.tags = tags
        self.ownderId = ownderId
        self.placeId = placeId
        self.addedBy = addedBy
        self.isActive = isActive
        self.isChecked = isChecked
    }
}
