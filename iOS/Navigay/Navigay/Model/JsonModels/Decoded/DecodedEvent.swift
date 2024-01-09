//
//  DecodedEvent.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedEvent: Identifiable, Codable {

    enum CodingKeys: String, CodingKey {

//        // country_id, region_id, city_id,
        case id
        case name
        case type = "type_id"
        case address
        case latitude
        case longitude
        case startDate = "start_date"
        case startTime = "start_time"
        case finishDate = "finish_date"
        case finishTime = "finish_time"
        case tags
        case location
        case poster
        case smallPoster = "poster_small"
        case isFree = "is_free"
        case isActive = "is_active"
        case lastUpdate = "updated_at"
        case about
        case tickets
        case fee
        case www
        case facebook
        case instagram
        case phone
        case place
        case city
    }
    
    let id: Int
    let name: String
    let type: EventType
    let startDate: String
    let startTime: String?
    let finishDate: String?
    let finishTime: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let poster: String?
    let smallPoster: String?
    let isFree: Bool
    let tags: [Tag]?
    let isActive: Bool
    let location: String?
    let lastUpdate: String
    
    let about: String?
    let fee: String?
    let tickets: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let phone: String?
    let place: DecodedPlace?
    let city: DecodedCity?
   // let countryId: Int?
   // let regionId: Int?
   // let cityId: Int?
}
