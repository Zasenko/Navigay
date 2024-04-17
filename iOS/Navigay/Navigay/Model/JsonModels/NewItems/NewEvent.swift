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
    let countryNameEn: String?
    let regionNameEn: String?
    let cityNameEn: String?
    let address: String?
    let latitude: Double
    let longitude: Double

    let repeatDates: [EventTimeToSend]
    let location: String?
    let about: String?
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
    
    let addedBy: Int
    let sessionKey: String
    
    let isActive: Bool
    let isChecked: Bool
    let adminNotes: String?
    
    let countryId: Int?
    let regionId: Int?
    let cityId: Int?
    
    init(name: String, type: Int, isoCountryCode: String, countryNameEn: String?, regionNameEn: String?, cityNameEn: String?, address: String?, latitude: Double, longitude: Double, repeatDates: [EventTimeToSend], location: String?, about: String?, isFree: Bool, tickets: String?, fee: String?, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, tags: [Int]?, ownderId: Int?, placeId: Int?, addedBy: Int, sessionKey: String, isActive: Bool, isChecked: Bool, adminNotes: String?, countryId: Int?, regionId: Int?, cityId: Int?) {
        self.name = name
        self.type = type
        self.isoCountryCode = isoCountryCode
        self.countryNameEn = countryNameEn
        self.regionNameEn = regionNameEn
        self.cityNameEn = cityNameEn
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.repeatDates = repeatDates
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
        self.sessionKey = sessionKey
        self.isActive = isActive
        self.isChecked = isChecked
        self.adminNotes = adminNotes
        self.countryId = countryId
        self.regionId = regionId
        self.cityId = cityId
    }
}
