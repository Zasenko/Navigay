//
//  DecodedOrganizer.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import Foundation

struct DecodedOrganizer: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        //case type = "type_id"
       // case address
     //   case latitude
      //  case longitude
        case lastUpdate = "updated_at"
        case avatar
        case mainPhoto = "main_photo"
        case photos
      //  case tags
     //   case timetable
        case about
        case www, facebook, instagram, phone
        case otherInfo = "other_info"
        case city
        case cityId = "city_id"
        case events
    }

    let id: Int
    let name: String
   // let type: PlaceType
  //  let address: String
   // let latitude: Double
   // let longitude: Double
    let lastUpdate: String
    let avatar: String?
    let mainPhoto: String?
    let photos: [String]?
  //  let tags: [Tag]?
  //  let timetable: [PlaceWorkDay]?
    let otherInfo: String?
    let about: String?
    let www: String?
    let facebook: String?
    let instagram: String?
    let phone: String?
    let city: DecodedCity?
    let cityId: Int?
    let events: EventsItemsResult?
}
