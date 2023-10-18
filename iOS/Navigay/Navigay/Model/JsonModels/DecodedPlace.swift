//
//  DecodedPlace.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 18.09.23.
//

import Foundation

struct DecodedPlace: Identifiable, Codable {

    let id: Int
    let name: String
    let type: PlaceType

    let photoSmall: String?
    let photoLarge: String?

    let address: String

    let latitude: Double
    let longitude: Double
    let tags: [Tag]?

    let workingTime: PlaceWorkingTime?
    
    let isActive: Bool
    
 //   let about: String?
  //  let www: String?
  //  let fb: String?
   // let insta: String?
  //  let phone: String?

 //   let countryId: Int
//    let regionId: Int
//    let cityId: Int?
    

}

struct PlaceWorkingTime: Codable {
    let days: [PlaceWorkDay]?
    let other: String?
}

struct PlaceWorkDay: Codable {
    let day: DayOfWeek
    let opening: String
    let closing: String
}
