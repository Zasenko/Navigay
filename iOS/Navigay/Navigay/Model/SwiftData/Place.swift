//
//  Place.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftData
import CoreLocation

@Model
final class Place {
    
//case countryId = "country_id"
//case regionId = "region_id"
//case cityId = "city_id"
    
    let id: Int
    var name: String = ""
    var type: PlaceType = PlaceType.other
    var avatar: String? = nil
    var mainPhoto: String? = nil
    var address: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var photos: [String] = []
    var about: String? = nil
    var tags: [Tag] = []
    var otherInfo: String? = nil
    var phone: String? = nil
    var www: String? = nil
    var facebook: String? = nil
    var instagram: String? = nil
    @Relationship(deleteRule: .cascade, inverse: \WorkDay.place) var timetable: [WorkDay] = []
    @Relationship(deleteRule: .cascade, inverse: \Event.place) var events: [Event] = []
    var city: City? = nil
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
    
    var isActive: Bool = true
    
    var isLiked: Bool = false

    @Transient lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    @Transient var tag: UUID = UUID()
    
    init(decodedPlace: DecodedPlace) {
        self.id = decodedPlace.id
        updatePlaceIncomplete(decodedPlace: decodedPlace)
    }
    
    func updatePlaceIncomplete(decodedPlace: DecodedPlace) {
        name = decodedPlace.name
        type = decodedPlace.type
        avatar = decodedPlace.avatar
        mainPhoto = decodedPlace.mainPhoto
        address = decodedPlace.address
        latitude = decodedPlace.latitude
        longitude = decodedPlace.longitude
        isActive = decodedPlace.isActive
        lastUpdateIncomplete = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        
        tags.removeAll()
        if let dacodedTags = decodedPlace.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
    }
    
    func updatePlaceComplite(decodedPlace: DecodedPlace) {
        
        name = decodedPlace.name
        type = decodedPlace.type
        avatar = decodedPlace.avatar
        mainPhoto = decodedPlace.mainPhoto
        address = decodedPlace.address
        latitude = decodedPlace.latitude
        longitude = decodedPlace.longitude
        isActive = decodedPlace.isActive
        about = decodedPlace.about
        photos = decodedPlace.photos ?? []//?.map( { $0.url} ) ?? []
        otherInfo = decodedPlace.otherInfo
        phone = decodedPlace.phone
        www = decodedPlace.www
        facebook = decodedPlace.facebook
        instagram = decodedPlace.instagram
        isActive = decodedPlace.isActive
        lastUpdateComplite = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        tags.removeAll()
        if let dacodedTags = decodedPlace.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
    }
    
    func getAllPhotos() -> [String] {
        var allPhotos: [String] = []
        if let mainPhoto {
            allPhotos.append(mainPhoto)
        }
        if !photos.isEmpty {
            photos.forEach( { allPhotos.append($0) } )
        }
        return allPhotos
    }
}


@Model
final class WorkDay {
    let id = UUID()
    var day: DayOfWeek
    var open: Date
    var close: Date
    var place: Place?
    
    init(workDay: PlaceWorkDay, place: Place? = nil) {
        self.day = workDay.day
        self.open = workDay.opening.dateFromString(format: "HH:mm") ?? .now
        self.close = workDay.closing.dateFromString(format: "HH:mm") ?? .now
    }
}
