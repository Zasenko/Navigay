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
    
    let id: Int
    var name: String = ""
    var type: PlaceType = PlaceType.other
    var photoSmall: String? = nil
    var photoBig: String? = nil
    var photos: [String] = []
    var about: String? = nil
    var address: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var tags: [Tag] = []
    var isLiked: Bool = false
    var otherInfo: String? = nil
    var phone: String? = nil
    var www: String? = nil
    var facebook: String? = nil
    var instagram: String? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \WorkDay.place) var timetable: [WorkDay] = []
    @Relationship(deleteRule: .cascade, inverse: \Event.place) var events: [Event] = []
    var city: City? = nil
    var isActive: Bool = true

    @Transient
    lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    @Transient
    var tag: UUID = UUID()
    
    init(decodedPlace: DecodedPlace) {
        self.id = decodedPlace.id
        updatePlaceIncomplete(decodedPlace: decodedPlace)
    }
    
    func updatePlaceIncomplete(decodedPlace: DecodedPlace) {
        name = decodedPlace.name
        type = decodedPlace.type
        photoSmall = decodedPlace.photoSmall
        photoBig = decodedPlace.photoLarge
        address = decodedPlace.address
        latitude = decodedPlace.latitude
        longitude = decodedPlace.longitude
        isActive = decodedPlace.isActive
        
        tags.removeAll()
        if let dacodedTags = decodedPlace.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
        
//        workDays.removeAll()
//        if let days = decodedPlace.workingTime?.days {
//            for day in days {
//                let workingDay = WorkDay(workDay: day)
//                workDays.append(workingDay)
//            }
//        }
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
