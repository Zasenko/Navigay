//
//  Event.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI
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
    var poster: String? = nil
    var smallPoster: String? = nil
    var isFree: Bool = false
    var tags: [Tag] = []
    
    var location: String? = nil
    var www: String? = nil
    var facebook: String? = nil
    var instagram: String? = nil
    var phone: String? = nil
    var tickets: String? = nil
    var fee: String? = nil
    
    var city: City? = nil
    var place: Place? = nil
    var owner: User? = nil
    var lastUpdateIncomplete: Date? = nil
    var lastUpdateComplite: Date? = nil
    
    var isLiked: Bool = false
    
    @Transient
    lazy var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    @Transient
    var tag: UUID = UUID()
    
    @Transient
    var image: Image?
    
    init(decodedEvent: DecodedEvent) {
        self.id = decodedEvent.id
        updateEventIncomplete(decodedEvent: decodedEvent)
    }
    
    func updateEventIncomplete(decodedEvent: DecodedEvent) {
        let lastUpdate = decodedEvent.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if lastUpdateIncomplete != lastUpdate {
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
            lastUpdateIncomplete = lastUpdate
        }
    }
    
    func updateEventComplete(decodedEvent: DecodedEvent) {
        let lastUpdate = decodedEvent.lastUpdate.dateFromString(format: "yyyy-MM-dd HH:mm:ss")
        if lastUpdateComplite != lastUpdate {
            updateEventIncomplete(decodedEvent: decodedEvent)
            about = decodedEvent.about
            www = decodedEvent.www
            facebook = decodedEvent.facebook
            instagram = decodedEvent.instagram
            phone = decodedEvent.phone
            tickets = decodedEvent.tickets
            fee = decodedEvent.fee
            lastUpdateComplite = lastUpdate
        }
    }
}
