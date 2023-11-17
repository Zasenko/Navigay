//
//  DecodedEvent.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedEvent: Identifiable, Codable {

    enum CodingKeys: String, CodingKey {
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
    //  fee, about, email, www, facebook, instagram, tickets, phone
       // case isChecked = "is_checked"
       // case placeId = "place_id"
     //   case countryId = "country_id"
     //   case regionId = "region_id"
     //   case cityId = "city_id"
       // case ownerId = "owner_id"
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
   // let fee: String?
    let tags: [Tag]?
    let isActive: Bool
    let location: String?
    let lastUpdate: String?
   // let about: String?
   // let email: String?
   // let www: String?
    //let facebook: String?
   // let instagram: String?
    //let tickets: String?
   // let phone: String?
  //  let placeId: Int?
   // let ownerId: Int?
   // let countryId: Int?
   // let regionId: Int?
   // let cityId: Int?
}
