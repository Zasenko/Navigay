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
    var smallPhoto: String? = nil
    var photo: String? = nil
    var photos: [String] = []
    var about: String? = nil
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
            smallPhoto = decodedCity.smallPhoto
            photo = decodedCity.photo
            lastUpdateIncomplete = lastUpdate
        }
    }
    
    func updateCityComplite(decodedCity: DecodedCity) {
        let lastUpdate = decodedCity.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if lastUpdateComplite != lastUpdate {
            updateCityIncomplete(decodedCity: decodedCity)
            about = decodedCity.about
            photos = decodedCity.photos ?? []
            lastUpdateComplite = lastUpdate
        }
    }
    
    func getAllPhotos() -> [String] {
        var allPhotos: [String] = []
        if let photo {
            allPhotos.append(photo)
        }
        photos.forEach( { allPhotos.append($0) } )
        return allPhotos
    }
}
