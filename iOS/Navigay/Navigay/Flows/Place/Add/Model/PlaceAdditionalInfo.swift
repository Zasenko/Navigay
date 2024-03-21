//
//  PlaceAdditionalInfo.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.11.23.
//

import Foundation

struct PlaceAdditionalInfo: Codable {

    let id: Int
    let about: [DecodedAbout]?
    let tags: [Int]?
    let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let email: String?
    let phone: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    
    init(id: Int, about: [DecodedAbout]?, tags: [Int]?, timetable: [PlaceWorkDay]?, otherInfo: String?, email: String?, phone: String?, www: String?, facebook: String?, instagram: String?) {
        self.id = id
        self.about = about
        self.tags = tags
        self.timetable = timetable
        self.otherInfo = otherInfo
        self.email = email
        self.phone = phone
        self.www = www
        self.facebook = facebook
        self.instagram = instagram
    }
}
