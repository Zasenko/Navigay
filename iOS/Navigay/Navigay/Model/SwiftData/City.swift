//
//  City.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import Foundation
import SwiftData

@Model
final class City {
    let id: Int
    var name: String = ""
    var photo: String? = nil
    var photos: [String] = []
    var about: String? = nil
    var isActive: Bool = false
    var region: Region? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Place.city) var places: [Place] = []
    @Relationship(deleteRule: .cascade, inverse: \Event.city) var events: [Event] = []
    
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
        
    init(decodedCity: DecodedCity) {
        self.id = decodedCity.id
        updateCityIncomplete(decodedCity: decodedCity)
    }
    
    func updateCityIncomplete(decodedCity: DecodedCity) {
        let lastUpdate = decodedCity.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if lastUpdateIncomplete != lastUpdate {
            name = decodedCity.name
            photo = decodedCity.photo
            isActive = decodedCity.isActive
            lastUpdateIncomplete = lastUpdate
        }
    }
    
    func updateCity(decodedCity: DecodedCity) {
        name = decodedCity.name
        photo = decodedCity.photo
        about = decodedCity.about
        isActive = decodedCity.isActive
    }
}
