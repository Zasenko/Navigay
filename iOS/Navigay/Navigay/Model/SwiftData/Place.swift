//
//  Place.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
import SwiftData
import CoreLocation

@Model
final class Place {
    
    private(set) var id: Int
    var name: String = ""
    var type: PlaceType = PlaceType.other
    var avatarUrl: String? = nil
    var mainPhotoUrl: String? = nil
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
    var isLiked: Bool = false
    
    var eventsCount: Int = 0
    var eventsDates: [Date] = []

    @Transient lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    @Transient var tag: UUID = UUID()
    @Transient var distanceText: String = ""
    
    @Transient var avatar: Image?
    @Transient var mainPhoto: Image?

    init(decodedPlace: DecodedPlace) {
        self.id = decodedPlace.id
        updatePlaceIncomplete(decodedPlace: decodedPlace)
    }
    
    func updatePlaceIncomplete(decodedPlace: DecodedPlace) {
        let lastUpdate = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateIncomplete != lastUpdate else { return }
        name = decodedPlace.name
        type = decodedPlace.type
        avatarUrl = decodedPlace.avatar
        address = decodedPlace.address
        latitude = decodedPlace.latitude
        longitude = decodedPlace.longitude
        tags.removeAll()
        if let dacodedTags = decodedPlace.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
        lastUpdateIncomplete = lastUpdate
    }
    
    func updatePlaceComplite(decodedPlace: DecodedPlace) {
        let lastUpdate = decodedPlace.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        guard lastUpdateComplite != lastUpdate else { return }
        
        name = decodedPlace.name
        type = decodedPlace.type
        avatarUrl = decodedPlace.avatar
        mainPhotoUrl = decodedPlace.mainPhoto
        address = decodedPlace.address
        latitude = decodedPlace.latitude
        longitude = decodedPlace.longitude
        tags.removeAll()
        if let dacodedTags = decodedPlace.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
        
        about = decodedPlace.about
        photos = decodedPlace.photos ?? []
        otherInfo = decodedPlace.otherInfo
        phone = decodedPlace.phone
        www = decodedPlace.www
        facebook = decodedPlace.facebook
        instagram = decodedPlace.instagram
        
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
    
    func isOpenNow() -> Bool {
        let currentDay = Date().dayOfWeek
        if let currentWorkDay = timetable.first(where: { $0.day == currentDay }) {
            let open = currentWorkDay.open
            let close = currentWorkDay.close
            if (open.isPastHour(of: .now) || open.isSameHour(as: .now)) && close.isFutureHour(of: .now) {
                return true
            } else if (open.isPastHour(of: .now) || open.isSameHour(as: .now)) && close.isPastHour(of: .now) {
                if close.isPastHour(of: open) || close.isSameHour(as: open) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getDistanceText(distance: Double, inKm: Bool = true) {
        if inKm {
            let distanceInKilometers = distance / 1000.0
            let formattedDistanceInKilometers = String(format: "%.1f", distanceInKilometers)
            distanceText = "\(formattedDistanceInKilometers) km."
        } else {
            let distanceInMiles = distance * 0.000621371 /// Преобразование в мили (1 метр = 0.000621371 миль)
            let formattedDistanceInKilometers = String(format: "%.1f", distanceInMiles)
            distanceText = "\(formattedDistanceInKilometers) miles"
        }
    }
    
    func getCountryCityText() -> String? {
        let countryName = city?.region?.country?.name
        let countryText = countryName ?? ""
        let cityName = city?.name
        let cityText = cityName == nil ? "" : "  •  \(cityName ?? "")"
        return "\(countryText)\(cityText)"
    }
}


@Model
final class WorkDay {
    private(set) var id = UUID()
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
