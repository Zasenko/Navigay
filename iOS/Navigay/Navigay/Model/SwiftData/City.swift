//
//  City.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData

@Model
final class City {
    private(set) var id: Int
    var name: String = ""
    var smallPhotoUrl: String? = nil
    var photoUrl: String? = nil
    var photosUrls: [String] = []
    var about: String? = nil
    
    var latitude: Double = 0
    var longitude: Double = 0
    var isCapital: Bool = false
    var isParadise: Bool = false
    
    var region: Region? = nil
    
    var eventsCount: Int = 0
    var placesCount: Int = 0
    var eventsDates: [Date] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Place.city) var places: [Place] = []
    @Relationship(deleteRule: .cascade, inverse: \Event.city) var events: [Event] = []
    
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
        
    @Transient var smallPhoto: Image?
    @Transient var photo: Image?

    init(decodedCity: DecodedCity) {
        self.id = decodedCity.id
        updateCityIncomplete(decodedCity: decodedCity)
    }
    
    func updateCityIncomplete(decodedCity: DecodedCity) {
        if let eventsCount = decodedCity.eventsCount {
            self.eventsCount = eventsCount
        }
        if let placesCount = decodedCity.placesCount {
            self.placesCount = placesCount
        }
        let lastUpdate = decodedCity.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateIncomplete != lastUpdate else { return }
        name = decodedCity.name
        smallPhotoUrl = decodedCity.smallPhoto
        latitude = decodedCity.latitude
        longitude = decodedCity.longitude
        isCapital = decodedCity.isCapital
        isParadise = decodedCity.isGayParadise
        lastUpdateIncomplete = lastUpdate
    }
    
    func updateCityComplite(decodedCity: DecodedCity) {
        if let eventsCount = decodedCity.eventsCount {
            self.eventsCount = eventsCount
        }
        if let placesCount = decodedCity.placesCount {
            self.placesCount = placesCount
        }
        let lastUpdate = decodedCity.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateComplite != lastUpdate else { return }
        name = decodedCity.name
        smallPhotoUrl = decodedCity.smallPhoto
        photoUrl = decodedCity.photo
        latitude = decodedCity.latitude
        longitude = decodedCity.longitude
        isCapital = decodedCity.isCapital
        isParadise = decodedCity.isGayParadise
        about = decodedCity.about
        photosUrls = decodedCity.photos ?? []
        lastUpdateComplite = lastUpdate
    }
    
    func getAllPhotos() -> [String] {
        var allPhotos: [String] = []
        if let photoUrl {
            allPhotos.append(photoUrl)
        }
        photosUrls.forEach( { allPhotos.append($0) } )
        return allPhotos
    }
}
