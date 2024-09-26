//
//  Organizer.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import SwiftUI
import SwiftData
//import CoreLocation

@Model
final class Organizer {
    
    private(set) var id: Int
    var name: String = ""
    var avatarUrl: String? = nil
    var mainPhotoUrl: String? = nil
    var photos: [String] = []
    var about: String? = nil
    var otherInfo: String? = nil
    var phone: String? = nil
    var www: String? = nil
    var facebook: String? = nil
    var instagram: String? = nil
    @Relationship(deleteRule: .cascade, inverse: \Event.organizer) var events: [Event] = []
    var city: City? = nil
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
    
    var eventsCount: Int = 0
    var eventsDates: [Date] = []
    
    @Transient var avatar: Image?
    @Transient var mainPhoto: Image?

    init(decodedOrganizer: DecodedOrganizer) {
        self.id = decodedOrganizer.id
        updateIncomplete(decodedOrganizer: decodedOrganizer)
    }
    
    func updateIncomplete(decodedOrganizer: DecodedOrganizer) {
        let lastUpdate = decodedOrganizer.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateIncomplete != lastUpdate else { return }
        name = decodedOrganizer.name
        avatarUrl = decodedOrganizer.avatar
        lastUpdateIncomplete = lastUpdate
    }
    
    func updateComplite(decodedOrganizer: DecodedOrganizer) {
        let lastUpdate = decodedOrganizer.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateComplite != lastUpdate else { return }
        
        name = decodedOrganizer.name
        avatarUrl = decodedOrganizer.avatar
        mainPhotoUrl = decodedOrganizer.mainPhoto
        about = decodedOrganizer.about
        photos = decodedOrganizer.photos ?? []
        otherInfo = decodedOrganizer.otherInfo
        phone = decodedOrganizer.phone
        www = decodedOrganizer.www
        facebook = decodedOrganizer.facebook
        instagram = decodedOrganizer.instagram
        lastUpdateComplite = lastUpdate
    }
    
    func getAllPhotos() -> [String] {
        var allPhotos: [String] = []
        if let mainPhotoUrl {
            allPhotos.append(mainPhotoUrl)
        }
        photos.forEach( { allPhotos.append($0) } )
        return allPhotos
    }
    
//    func getCountryCityText() -> String? {
//        let countryName = city?.region?.country?.name
//        let countryText = countryName ?? ""
//        let cityName = city?.name
//        let cityText = cityName == nil ? "" : "  •  \(cityName ?? "")"
//        return "\(countryText)\(cityText)"
//    }
}
