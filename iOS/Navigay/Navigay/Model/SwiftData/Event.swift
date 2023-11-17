//
//  Event.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftData
import CoreLocation

@Model
final class Event {
    
    let id: Int
    var name: String = ""
    var about: String? = nil
    
    var type: EventType = EventType.other
    var startDate: Date = Date.now
    var startTime: Date? = nil
    var finishDate: Date? = nil
    var finishTime: Date? = nil
    var address: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
   // var isCoverHorizontal: Bool = false
    var poster: String? = nil
    var smallPoster: String? = nil
    var isFree: Bool = false
    var tags: [Tag] = []
    var isActive: Bool = true
    
    var location: String? = nil
    var www: String? = nil
    var facebook: String? = nil
    var instagram: String? = nil
    var tickets: String? = nil
    
    //TODO
//    var placeId: Int? = nil
//    var ownerId: Int? = nil
    var city: City? = nil
    var place: Place? = nil
    
    
    
    var isLiked: Bool = false
    
    @Transient
    lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    @Transient
    var tag: UUID = UUID()
    
    init(decodedEvent: DecodedEvent) {
        self.id = decodedEvent.id
        updateEventIncomplete(decodedEvent: decodedEvent)
    }
    
    func updateEventIncomplete(decodedEvent: DecodedEvent) {
        name = decodedEvent.name
        type = decodedEvent.type
        startDate = decodedEvent.startDate.dateFromString(format: "yyyy-MM-dd") ?? .now
        startTime = decodedEvent.startTime?.dateFromString(format: "HH:mm:ss")
        finishDate = decodedEvent.finishDate?.dateFromString(format: "yyyy-MM-dd")
        finishTime = decodedEvent.finishTime?.dateFromString(format: "HH:mm:ss")
        address = decodedEvent.address
        latitude = decodedEvent.latitude
        longitude = decodedEvent.longitude
        poster = decodedEvent.poster
        smallPoster = decodedEvent.smallPoster
        isFree = decodedEvent.isFree
        tags.removeAll()
        if let dacodedTags = decodedEvent.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
        location = decodedEvent.location
        isActive = decodedEvent.isActive
        
        @Transient
        lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func updateEvent(decodedEvent: DecodedEvent) {
        name = decodedEvent.name
        type = decodedEvent.type
        startDate = startDate
        startTime = decodedEvent.startTime?.dateFromString(format: "HH:mm:ss")
        finishDate = decodedEvent.finishDate?.dateFromString(format: "yyyy-MM-dd")
        finishTime = decodedEvent.finishTime?.dateFromString(format: "HH:mm:ss")
        address = decodedEvent.address
        latitude = decodedEvent.latitude
        longitude = decodedEvent.longitude
        poster = decodedEvent.poster
        smallPoster = decodedEvent.smallPoster
        isFree = decodedEvent.isFree
        tags.removeAll()
        if let dacodedTags = decodedEvent.tags {
            for tag in dacodedTags {
                tags.append(tag)
            }
        }
        isActive = decodedEvent.isActive
        location = decodedEvent.location
//        about = decodedEvent.about
//        www = decodedEvent.www
//        facebook = decodedEvent.facebook
//        instagram = decodedEvent.instagram
//        tickets = decodedEvent.tickets
    }
}
