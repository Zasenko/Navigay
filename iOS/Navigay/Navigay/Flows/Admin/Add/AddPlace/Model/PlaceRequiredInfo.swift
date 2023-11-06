//
//  PlaceRequiredInfo.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import Foundation

struct PlaceRequiredInfo: Codable {
    
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
    
    init(name: String, type: Int, isoCountryCode: String, countryOrigin: String?, countryEnglish: String?, regionOrigin: String?, regionEnglish: String?, cityOrigin: String?, cityEnglish: String?, address: String, latitude: Double, longitude: Double) {
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
    }
}
