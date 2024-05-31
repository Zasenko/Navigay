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
    
    @Relationship(deleteRule: .cascade, inverse: \Region.country) var regions: [Region] = []
    
    @Transient var locatinsCountString: String? = nil
    
    init(decodedCountry: DecodedCountry) {
        self.id = decodedCountry.id
        self.isoCountryCode = decodedCountry.isoCountryCode
        self.updateCountryIncomplete(decodedCountry: decodedCountry)
    }
    
    func updateCountryIncomplete(decodedCountry: DecodedCountry) {
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
    
    func getLocationsCountText(eventsCount: Int?, placesCount: Int?) {
        var text = ""
        if let eventsCount {
            if eventsCount > 0 {
                text.append(contentsOf: "\(eventsCount) events")
            }
        }
        if let placesCount {
            
            if placesCount > 0 {
                if let eventsCount,
                   eventsCount > 0 {
                    text.append(contentsOf: "  •  \(placesCount) places")
                } else {
                    text.append(contentsOf: "\(placesCount) places")

                }
            }
        }
        if !text.isEmpty {
            self.locatinsCountString = text
        }
    }
}
