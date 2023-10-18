//
//  City.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftData

@Model
final class City {
    let id: Int
    var name: String = ""
    var photo: String? = nil
    var about: String? = nil
    var isActive: Bool = true
    var region: Region? = nil
    @Relationship(deleteRule: .cascade, inverse: \Place.city) var places: [Place] = []
    @Relationship(deleteRule: .cascade, inverse: \Event.city) var events: [Event] = []
        
    init(decodedCity: DecodedCity) {
        self.id = decodedCity.id
        updateCityIncomplete(decodedCity: decodedCity)
    }
    
    func updateCityIncomplete(decodedCity: DecodedCity) {
        name = decodedCity.name
        photo = decodedCity.photo
        isActive = decodedCity.isActive
    }
    
    func updateCity(decodedCity: DecodedCity) {
        name = decodedCity.name
        photo = decodedCity.photo
        about = decodedCity.about
        isActive = decodedCity.isActive
    }
}
