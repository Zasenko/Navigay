//
//  Country.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftData

@Model
final class Country {
    let id: Int
    var name: String = ""
    var flagEmoji: String = "🏳️‍🌈"
    var about: String? = nil
    var photo: String? = nil
    var isActive: Bool = true
    var showRegions: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Region.country) var regions: [Region] = []
        
    init(decodedCountry: DecodedCountry) {
        self.id = decodedCountry.id
        self.updateCountryIncomplete(decodedCountry: decodedCountry)
    }
    
    func updateCountryIncomplete(decodedCountry: DecodedCountry) {
        flagEmoji = decodedCountry.flagEmoji
        name = decodedCountry.name
        photo = decodedCountry.photo
        showRegions = decodedCountry.showRegions
        isActive = decodedCountry.isActive
    }
    
    func updateCountry(decodedCountry: DecodedCountry) {
        flagEmoji = decodedCountry.flagEmoji
        name = decodedCountry.name
        photo = decodedCountry.photo
        showRegions = decodedCountry.showRegions
        about = decodedCountry.about
        isActive = decodedCountry.isActive
    }
}
