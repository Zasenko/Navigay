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
    
    var latitude: Double = 0
    var longitude: Double = 0
    var isCapital: Bool = false
    var isParadise: Bool = false
    
    var region: Region? = nil
    
    @Transient var locatinsCountString: String? = nil
    
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
        guard lastUpdateIncomplete != lastUpdate else { return }
        name = decodedCity.name
        smallPhoto = decodedCity.smallPhoto
        latitude = decodedCity.latitude
        longitude = decodedCity.longitude
        isCapital = decodedCity.isCapital
        isParadise = decodedCity.isGayParadise
        lastUpdateIncomplete = lastUpdate
    }
    
    func updateCityComplite(decodedCity: DecodedCity) {
        let lastUpdate = decodedCity.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateComplite != lastUpdate else { return }
        
        name = decodedCity.name
        smallPhoto = decodedCity.smallPhoto
        photo = decodedCity.photo
        latitude = decodedCity.latitude
        longitude = decodedCity.longitude
        isCapital = decodedCity.isCapital
        isParadise = decodedCity.isGayParadise
        about = decodedCity.about
        photos = decodedCity.photos ?? []
        lastUpdateComplite = lastUpdate
    }
    
    func getAllPhotos() -> [String] {
        var allPhotos: [String] = []
        if let photo {
            allPhotos.append(photo)
        }
        photos.forEach( { allPhotos.append($0) } )
        return allPhotos
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
