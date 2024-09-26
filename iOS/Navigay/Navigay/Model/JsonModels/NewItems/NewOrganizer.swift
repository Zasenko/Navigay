//
//  NewOrganizer.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.09.24.
//

import Foundation

struct NewOrganizer: Codable {
    
    let name: String
    let isoCountryCode: String
    let countryNameEn: String?
    let regionNameEn: String?
    let cityNameEn: String?
    let about: String?
    let otherInfo: String?
    let email: String?
    let phone: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    
    let ownderId: Int?
    
    let addedBy: Int?
    let sessionKey: String
    
    let isActive: Bool
    let isChecked: Bool
    let adminNotes: String?
    
    let countryId: Int?
    let regionId: Int?
    let cityId: Int?
    
    init(name: String, isoCountryCode: String, countryNameEn: String?, regionNameEn: String?, cityNameEn: String?, about: String?, otherInfo: String?, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?, ownderId: Int?, addedBy: Int?, tocken: String, isActive: Bool, isChecked: Bool, adminNotes: String?, countryId: Int?, regionId: Int?, cityId: Int?) {
        self.name = name
        self.isoCountryCode = isoCountryCode
        self.countryNameEn = countryNameEn
        self.regionNameEn = regionNameEn
        self.cityNameEn = cityNameEn
        self.about = about
        self.otherInfo = otherInfo
        self.email = email
        self.phone = phone
        self.www = www
        self.facebook = facebook
        self.instagram = instagram
        self.ownderId = ownderId
        self.addedBy = addedBy
        self.sessionKey = tocken
        self.isActive = isActive
        self.isChecked = isChecked
        self.adminNotes = adminNotes
        self.countryId = countryId
        self.regionId = regionId
        self.cityId = cityId
    }
}
