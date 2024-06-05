//
//  Country.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import Foundation
import SwiftData

@Model
final class Country {
    
    let id: Int
    let isoCountryCode: String
    
    var name: String = ""
    var flagEmoji: String = "🏳️‍🌈"
    var photo: String? = nil
    var about: String? = nil
    var showRegions: Bool = false
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
    
    var eventsCount: Int? = nil
    var placesCount: Int? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Region.country) var regions: [Region] = []
        
    init(decodedCountry: DecodedCountry) {
        self.id = decodedCountry.id
        self.isoCountryCode = decodedCountry.isoCountryCode
        self.updateCountryIncomplete(decodedCountry: decodedCountry)
    }
    
    func updateCountryIncomplete(decodedCountry: DecodedCountry) {
        if let eventsCount = decodedCountry.eventsCount {
            self.eventsCount = eventsCount
        }
        if let placesCount = decodedCountry.placesCount {
            self.placesCount = placesCount
        }
        let lastUpdate = decodedCountry.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateIncomplete != lastUpdate else { return }
        flagEmoji = decodedCountry.flagEmoji
        name = decodedCountry.name
        showRegions = decodedCountry.showRegions
        lastUpdateIncomplete = lastUpdate
    }
    
    func updateCountryComplite(decodedCountry: DecodedCountry) {
        let lastUpdate = decodedCountry.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateComplite != lastUpdate else { return }
        flagEmoji = decodedCountry.flagEmoji
        name = decodedCountry.name
        photo = decodedCountry.photo
        showRegions = decodedCountry.showRegions
        about = decodedCountry.about
        lastUpdateComplite = lastUpdate
        
    }
}
